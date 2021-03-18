/*
 * Copyright (C) 2009-2017 SAP SE or an SAP affiliate company. All rights reserved.
 */
sap.ui.define(
	["sap/ui/core/mvc/Controller",
	"sap/fin/arp/lib/lineitems/controller/NavigationController",
	"sap/fin/arp/lib/lineitems/fragments/BlockItems",
	"sap/fin/arp/lib/lineitems/fragments/ChangeDocuments",
	"sap/fin/arp/lib/lineitems/fragments/ShareActionSheetController",
	"sap/fin/arp/lib/lineitems/util/ExtensionHelper",
	"sap/fin/arp/lib/lineitems/util/Formatter",
	"sap/fin/central/lib/interop/ODataVersionManager",
	"sap/fin/central/lib/library",
	"sap/m/MessageBox",
	"sap/m/Button",
	"sap/m/MessageToast",
	"sap/m/Text",
	"sap/ui/layout/form/SimpleForm",
	"sap/ui/core/Title",
	"sap/ui/model/Filter",
	"sap/ui/model/FilterOperator",
	"sap/ui/model/json/JSONModel",
	"sap/ui/comp/navpopover/LinkData",
	"sap/ui/Device"
	//,"sap/ushell/services/Container"
	],
	function(Controller, NavigationController, BlockItems, ChangeDocuments, ShareActionSheetController, ExtensionHelper,
		Formatter, ODataVersionManager, CentralLib, MessageBox, Button, MessageToast, Text, SimpleForm, Title, Filter, FilterOperator, 
		JSONModel, LinkData, Device/*, UshellContainer*/) { // UshellContainer not defined yet, waiting for it's AMD migration
		"use strict";
		/**
		 * @name sap.fin.arp.lib.lineitems.controller.AbstractController
		 * @class Abstract Controller for AP/AR Line Item Apps
		 */
		
		var AbstractController = Controller.extend("sap.fin.arp.lib.lineitems.controller.AbstractController", {
			/**
			 * @memberOf sap.fin.arp.lib.lineitems.controller.AbstractController
			 * @lends sap.fin.arp.lib.lineitems.controller.AbstractController
			 * @augments sap.ui.core.mvc.Controller
			 */
			
			BLOCK_ACTION_TYPE_PMT: "BLOCK_PAYMENT",
			BLOCK_ACTION_TYPE_DUN: "BLOCK_DUNNING",
			
			VALUE_HELP_DUMMY_KEY: "DONT_SEND_TO_BACKEND",
			MAX_NUMBER_OF_ITEMS: 50,
			BUSY_INDICATOR_DELAY: 500, // in milliseconds

			oNavigationController: null,

			oi18n: null,
			oi18nLib: null,
			sPrefix: "", // set by descendant of this class

			constructor: function() {
				
				this.bSuppressOverlayAtStart = true;
				this.sAccountingDocumentSemanticObject = "AccountingDocument";
			},

			onInit: function() {
				this.oView = this.getView();
				this.oComponent = this.getOwnerComponent();
				this.oModel = this.oComponent.getModel();
				
				this.oi18n = this.oComponent.getModel("i18n").getResourceBundle();
				this.oi18nLib = this.getOwnerComponent().getModel("i18nLib").getResourceBundle();
				Formatter.setResourceBundle(this.oi18nLib);
				
				this.oErrorHandler = this.oComponent.oErrorHandler;
				this.oRouter = sap.ui.core.UIComponent.getRouterFor(this);

				this.oPage = this.byId(this.sPrefix + ".Page");
				this.oPageTitle = this.byId(this.sPrefix + ".PageTitle");
				this.oTable = this.byId(this.sPrefix + ".TableItems");
				this.oSmartTable = this.byId(this.sPrefix + ".SmartTableItems");
				this.oSmartFilterBar = this.byId(this.sPrefix + ".SmartFilterBar");
				
				this.oView.addStyleClass(this.oComponent.getContentDensityClass());
				
				//show busy indicator while metadata is loaded
				var oViewModel = new JSONModel({
					busy: true
				});
				this.oView.setModel(oViewModel, "appView");

				this.oModel.metadataLoaded().then(function() {
					oViewModel.setProperty("/busy", false);
				});
				
				// initialize the ODataVersionManager and trigger check
				this.oModel.attachMetadataLoaded(jQuery.proxy(function(){
					this.checkODataSchemaVersion(new ODataVersionManager(this.oModel, "Item"));	
					}, this ));

				this.bItemsLoaded = false;
				this.bValueHelpsInitialized = false;
				this.mCompany = {};
				
				this.oTable.attachFilter(this.onListFilterChange);
				// avoid separate $count requests
				this.oModel.setDefaultCountMode(sap.ui.model.odata.CountMode.Inline);
				
				// page Model: page specific attributes
				var oPageModel = new JSONModel({
						headerExpanded : true
				});
				this.oView.setModel(oPageModel, "page");
				
				// set groupHeaderFormatter of icon columns to get the name and not the code if the user groups by this column
				this.setGroupHeaderFormatter();
				
				this.aSelectedKeys = [];
				this.bTableSorted = false;
				
				// init finished: this must be always the last statement in the onInit method
				this.initDeferred.resolve();
			},
			
			cleanUpNavController: function() {
				this.oNavigationController.destroy();
			},

			checkODataSchemaVersion: function(oODataVersionManager) {
				// verify that the server's OData Service has not changed in an incompatible manner
				// (by checking the Schema Version Id)
				var i18nBundle = this.oi18nLib;
				if (oODataVersionManager.getServiceVersion() > 1) {
					// this application only supports the backend OData Service Schema Version 1
					
					/* eslint-disable no-undef, no-unused-vars, sap-timeout-usage */
					// actually browser function but the environment variable is not recognized by jslint
					var oTimeout = setTimeout(function() {
						MessageBox.show(i18nBundle.getText("INCOMPATIBLE_SERVER"), {
							icon: MessageBox.Icon.WARNING
						});
					}, 2000);
					/* eslint-enable no-undef, no-unused-vars, sap-timeout-usage */
				}
			},
			
			checkOnVersionPopup: function() {
				// get version information for developer debugging only
				var oVersionRequest = jQuery.sap.getUriParameters().get("version");
				if (oVersionRequest) {
					// get the properties file where the version is entered
					
					var processVersionJson = function(sUrl) {
						var oJson = jQuery.sap.sjax({
							url: sUrl
						});
						
						var oVersion = {
							version: "UNKNOWN",
							buildId: "UNKNOWN",
							revision: "UNKNOWN"
						};
						
						if (oJson.statusCode !== 200) {
							// version.json file could not be retrieved
							return oVersion;
						}
						
						var oJsonData;
						if (typeof oJson.data === "string") {
							oJsonData = JSON.parse(oJson.data);
						} else {
							oJsonData = oJson.data;
						}
						oVersion.version = oJsonData.version;
						oVersion.buildId = oJsonData.buildId;
						
						if (typeof oJsonData.revision !== "undefined") {
							if (/^\${.*}$/.test(oJsonData.revision)) {
								oVersion.revision = "n/a";
							} else {
								// first 10 hex digits only
								oVersion.revision = oJsonData.revision.substr(0, 9);
							}
						}
						return oVersion;
					};
					
					var sUrl = jQuery.sap.getModulePath(this.sPrefix + ".version", ".json");
					var oAppVersion = processVersionJson(sUrl);
					
					sUrl = jQuery.sap.getModulePath("sap.fin.arp.lib.lineitems.version", ".json");
					// Issue: URL now points to the subdirectory sap/fin/arp/lib/lineitems within the context path
					// therefore, we need to cut that part out, as the version.json is located in the root of the context path
					sUrl = sUrl.replace(new RegExp("sap/fin/arp/lib/lineitems/"), "");
					var oLibVersion = processVersionJson(sUrl);
						
					var sMessageText = this.oi18nLib.getText("VERSION_MESSAGE", [
						oAppVersion.version, oAppVersion.buildId, oAppVersion.revision, oLibVersion.version, oLibVersion.buildId, oLibVersion.revision
					]);
					
					MessageBox.show(sMessageText, {
						icon: MessageBox.Icon.INFORMATION
					});
				}
			},
			
			createKey: function(oParams) {
				// creates a unique string from the four key fields
				// returns 'undefined', if a key field is missing (e.g. for a total line)
				// In addition, the etag is included (not a key field, but it is needed in ChangeDocuments for optimistic locking).
				if (typeof oParams.AccountingDocument !== "undefined" && typeof oParams.FiscalYear !== "undefined" && typeof oParams.AccountingDocumentItem !== "undefined" && typeof oParams.CompanyCode !== "undefined" && typeof oParams.etag !== "undefined") {
					return oParams.AccountingDocument.toString() + "|" + oParams.FiscalYear.toString() + "|" + oParams.AccountingDocumentItem.toString() + "|" + oParams.CompanyCode.toString() + "|" + oParams.etag.toString();
				}
			},
			
			getKey: function(sKey) {
				var aKey = sKey.split("|");
				var oKey = {};
				oKey.AccountingDocument = aKey[0];
				oKey.FiscalYear = aKey[1];
				oKey.AccountingDocumentItem = aKey[2];
				oKey.CompanyCode = aKey[3];
				oKey.etag = aKey[4];
				
				if (aKey.length > 5) {
					MessageBox.show(this.oi18nLib.getText("SEVERE_ERROR"), {
						icon: MessageBox.Icon.ERROR
					});
				}
				return oKey;
			},
			
			initNavigationController: function() {
				this.oNavigationController = new NavigationController(this);
				
				// check navigation targets with previously stored targets from onPrefetchNavTargets
				if (this.oNavTargets) {
					this.checkNavigationSupported(this.oNavTargets);
				}
			},
			
			onPrefetchNavTargets: function(oEvent) {
				// Event is fired by the SmartLinkControl, either before or after the Navigation Controller has been initialized.
				if (this.oNavigationController) {
					// Nav Controller is already initialized, check nav targets
					this.checkNavigationSupported(oEvent.getParameter("semanticObjects"));
				} else {
					// store navigation targets to evaluate later by initNavigationController
					this.oNavTargets = oEvent.getParameter("semanticObjects");
				}
			},
			
			checkNavigationSupported: function(oNavTargets) {
				var oAbstractController = this;
				var fOnAfterProcess = function(oNavTargetsModel) {
					oAbstractController.oView.setModel(oNavTargetsModel, "SupportedNavigations");
				};
				this.oNavigationController.checkNavigationSupported(oNavTargets, fOnAfterProcess);
			},
			
			checkForNavigation: function(fnMappingCallback) {
				var oController = this;
				var oNavFinishPromise = jQuery.Deferred();
				
				if (!this.oNavigationController) {
					this.initNavigationController();
				}
				
				oNavFinishPromise.done(jQuery.proxy(function(oAppData) {
					
					if (!oAppData.isInitialStart) {
						if (fnMappingCallback) {
							oAppData.selectionVariant = fnMappingCallback(oAppData.selectionVariant);
						}
						if (oAppData.selectionVariant) {
							// put data into filter bar
							if (!oAppData.hasOnlyDefaults || oController.oSmartFilterBar.isCurrentVariantStandard()) {
								// A default variant could be loaded. We have to clear the variant and we have to clear all the selections
								// in the SmartFilterBar. However, we want to set the defaults (CustomClearingStatus, KeyDate etc.),
								// so that they are pre-filled, unless they are overwritten by the navigation parameters.
								oController.oSmartFilterBar.clearVariantSelection();
								oController.oSmartFilterBar.clear();
								var sClearingStatus = "";
								if(oAppData.oSelectionVariant){
									var aClearingStatus = oAppData.oSelectionVariant.getValue("CustomClearingStatus");
									if(aClearingStatus){
										sClearingStatus = aClearingStatus[0].Low;
									}
								}
								oController.setSmartFilterBarDefaults(sClearingStatus);
								var bOverwriteFilter = false;
								var bSetVisibleInFilterBar = true;
								oController.setSmartFilterBarFilterData(oAppData.selectionVariant, bOverwriteFilter, bSetVisibleInFilterBar);
								
								// restore the visibleInFilterBar properties
								if(oAppData.customData && oAppData.customData.visibleInFilterBar){
									oController.oCustomData.setVisibleInFilterBar(oAppData.customData.visibleInFilterBar);
								}
							}
							
							// press go button
							if ((oAppData.customData && oAppData.customData.bItemsLoaded === false) || oAppData.hasOnlyDefaults) {
								oController.bItemsLoaded = false;
							} else {
								oController.oSmartFilterBar.search(); // same as press search button
								oController.bItemsLoaded = true;
							}
						}
						if (oAppData.tableVariantId) {
							oController.oSmartTable.setCurrentVariantId(oAppData.tableVariantId);
						}
					}

					oController.bNavigationFinished = true; // used for tests
					oController.checkOnVersionPopup();
				}, this));
				oNavFinishPromise.fail(jQuery.proxy(oController.checkOnVersionPopup, oController));
				
				this.oNavigationController.processInboundNavigation(oNavFinishPromise);
			},
			
			processBeforeSmartLinkPopoverOpens: function(oParameters, sSelectionVariant) {
				var oSmartLink = this.byId(oParameters.originalId);
				// Special handling for the "Clearing Document" and "Clearing Date" links.
				if (oSmartLink && (oSmartLink.data("columnId") === this.sPrefix + ".LinkClearingAccountingDocument" || oSmartLink.data("columnId") === this.sPrefix + ".LinkClearingDate") && oParameters.semanticAttributes.AccountingDocument && oParameters.semanticAttributes.ClearingAccountingDocument) {
					// The value of the navigation parameter "AccountingDocument" must be set to the value of the
					// ClearingAccountingDocument parameter (if available), because we want to hand over the ClearingDocument number in the target links.
					oParameters.semanticAttributes.AccountingDocument = oParameters.semanticAttributes.ClearingAccountingDocument;
					oParameters.semanticAttributes.FiscalYear = oParameters.semanticAttributes.ClearingDocFiscalYear;
				}
				// take care of all navigation related tasks
				this.oNavigationController.processBeforeSmartLinkPopoverOpens(oParameters, sSelectionVariant);
			},
			
			modifyPopoverActions: function(oEventParameters, sSemanticObject, sSelfNavigationText) {

				if (!this.oCrossApplicationNavigation) {
					this.oCrossApplicationNavigation = sap.ushell.Container.getService("CrossApplicationNavigation");
				}

				if (sSemanticObject === this.sOwnSemanticObject) {

					var aActions = oEventParameters.actions;

					var oNavArguments = {
						target: {
							semanticObject: sSemanticObject,
							action: "manageLineItems"
						},
						params: {}
					};

					// Semantic attributes are already set by processBeforeSmartLinkPopoverOpens, thus they are available in oEventParameters
					oNavArguments.params[sSemanticObject] = oEventParameters.semanticAttributes[sSemanticObject];
					oNavArguments.params.CompanyCode = oEventParameters.semanticAttributes.CompanyCode;

					// we do not want the key date to be defaulted, thus hand over an initial key date
					oNavArguments.params.KeyDate = "";

					// Problem: If the user navigates via this "Show Line Items for this Customer/Vendor" link,
					// then deletes the customer/vendor from the filter bar and presses search, and then again
					// tries to navigate with the same customer/vendor -> nothing would happen, since the
					// target URL is already set.
					// Solution: Add a dummy parameter to the outbound parameters, which is unique
					// (use a timestamp), so that the URL changes, but which has no other meaning.
					oNavArguments.params.localState = (new Date()).toISOString().substring(2).replace(/:/g, "");

					// Use case: Navigation from own app via link "Show Line Items for this Customer/Vendor"
					// Although technically it's a navigation, the user stays in the same app. Thus, the table variant
					// should not change. Therefore, hand over the table variant via an additional URL parameter.
					oNavArguments.params.tableVariantId = this.oSmartTable.getCurrentVariantId();

					// construct new link
					var sExternalHash = this.oCrossApplicationNavigation.hrefForExternal(oNavArguments,this.getOwnerComponent());
					var sInternalHash = this.externalToInternalHash(sExternalHash);
					var sKey = this.sPrefix + ".customLink.manageLineItems";
					var oLinkData = new LinkData({
						text: sSelfNavigationText,
						href: sInternalHash,
						key: sKey
					});

					// insert link "Show line items for this customer/vendor" at first position
					aActions.unshift(oLinkData);
					return aActions;

				} else if (sSemanticObject === this.sAccountingDocumentSemanticObject) {
					// Special handling for AccountingDocument to remove navigation to createSinglePayment;
					// Special handling for AccountingDocument to remove navigation to resetClearedItems
					// (AccountingDocument and FiscalYear would be handed over instead of ClearingAccountingDocument and ClearingFiscalYear);
					// Remove action "manage" (app Manage Jounrnal Entries) as navigation to it will be inserted at top of popover below in code
					aActions = [];
					
					var bSuppressResetClearedItemsLink = false;
					var oSmartLink = this.byId(oEventParameters.originalId);
					if (oSmartLink && (oSmartLink.data("columnId") === this.sPrefix + ".LinkAccountingDocument")){
						bSuppressResetClearedItemsLink = true;
					}
					
					var oURLParsing = sap.ushell.Container.getService("URLParsing");
					var bActionManageGranted = false;
					
					for (var i = 0; i < oEventParameters.actions.length; i++) {
						var sAction = oURLParsing.parseShellHash(oEventParameters.actions[i].getHref()).action;
						if (sAction === "manage") {
							bActionManageGranted = true;
						}
						if (sAction !== "createSinglePayment" && sAction !== "manage" &&
						   (sAction !== "resetClearedItems" || !bSuppressResetClearedItemsLink)) {
							aActions.push(oEventParameters.actions[i]);
						}
					}
					
					// insert links to journal entry line item and journal entry (header) at top of popover actions available
					if (bActionManageGranted === true) {
						oNavArguments = {
							target: {
								semanticObject: sSemanticObject,
								action: "manage"
							},
							params: {}
						};
						
						// Semantic attributes are already set by processBeforeSmartLinkPopoverOpens, thus they are available in oEventParameters
						// Navigation to journal entry header (don't provide line item number)
						oNavArguments.params[sSemanticObject] = oEventParameters.semanticAttributes[sSemanticObject];
						oNavArguments.params.CompanyCode = oEventParameters.semanticAttributes.CompanyCode;
						oNavArguments.params.FiscalYear = oEventParameters.semanticAttributes.FiscalYear;
					
						// construct new link to journal entry header
						sExternalHash = this.oCrossApplicationNavigation.hrefForExternal(oNavArguments,this.getOwnerComponent());
						sInternalHash = this.externalToInternalHash(sExternalHash);
						sKey = this.sPrefix + ".customLink.manageJournalEntryHeader";
						oLinkData = new LinkData({
							text: this.oi18nLib.getText("POPOVER_JE_HEADER_LINK"),
							href: sInternalHash,
							key: sKey
						});
						
						// insert link "Manage Journal Entry" (header) at second position
						aActions.unshift(oLinkData);
						
						// Navigation to journal entry line item
						var sPrefixItem = "000";  // BSEG has line item number of length 3, ACDOCA has line item number length of 6 --> add "000" to item number
						oNavArguments.params.AccountingDocumentItem = sPrefixItem.concat(oEventParameters.semanticAttributes.AccountingDocumentItem);

						// construct new link to journal entry line item
						sExternalHash = this.oCrossApplicationNavigation.hrefForExternal(oNavArguments,this.getOwnerComponent());
						sInternalHash = this.externalToInternalHash(sExternalHash);
						sKey = this.sPrefix + ".customLink.manageJournalEntryItem";
						oLinkData = new LinkData({
							text: this.oi18nLib.getText("POPOVER_JE_ITEM_LINK"),
							href: sInternalHash,
							key: sKey
						});
						
						// insert link "Manage Journal Entry Line Item" at first position
						aActions.unshift(oLinkData);
					}
					return aActions;
				} else {
					return oEventParameters.actions;
				}
			},
			
			externalToInternalHash: function(sExternalHash){
				








				return decodeURIComponent(sExternalHash);
			},
			
			onPopoverLinkPressed: function() {
				this.oNavigationController.storeForBackNavigation(); // store local state for back navigation
			},
			
			onSearchButtonPressed: function() {
				this.bSuppressOverlayAtStart = false;
				this.oCustomData.setItemsLoaded(true); // remember that search was already processed
			},
			
			onDataReceived: function() {
				this.oTable.setShowOverlay(false);
			},
			
			onShowOverlay: function(event) {
				// IM 1570613706
				// storing custom control state in smart filterbar via oSmartFilterBar.setDataSuiteFormat ( EventHandler of SmartFilterbar.initialise())
				// will lead to the fact that overlay gets displayed on top of the table.
				// This is not the intended behaviour at startup. At end of startup we do not want to see an overlay on top
				// of the table
				if (this.bSuppressOverlayAtStart) {
						this.oTable.setShowOverlay(false);
						//event.getParameter("overlay").show = false;
				} else {
					this.oTable.setShowOverlay(true);
				}
				this.updateButtonBehavior([]);
			},
			
			onAfterTableVariantSave: function() {
				this.oNavigationController.storeForBackNavigation(); // store local state for back navigation
			},
			
			onAfterVariantLoad: function(oEvent) {
				// Caution: Be aware that this event is also fired, when the user clicks on "Cancel"
				// in the "Filters" popup of the SmartFilterBar
				
				// We have to set the date fields temporarily visible, because the SmartFilterBar ignores them
				// in getDataSuiteFormat if they are invisible. The visibility is set correctly afterwards in
				// setSmartFilterBarFilterData according to the CustomClearingStatus.
				this.oView.byId(this.sPrefix + ".DateKeyDate").setVisible(true);
				this.oView.byId(this.sPrefix + ".DateClearingDate").setVisible(true);
				this.oView.byId(this.sPrefix + ".DatePostingDate").setVisible(true);
				
				// after a filter variant is loaded, we have to set the values of the custom controls, since the filter bar won't do it
				// this is done by calling setSmartFilterBarFilterData where the controls are set according to current filter
				var oSelectionVariant = new CentralLib.nav.SelectionVariant(oEvent.getSource().getDataSuiteFormat());
				var oSelectionVariantDelta = new CentralLib.nav.SelectionVariant();
				
				










				
				// set defaults if necessary, since CustomClearingStatus and DueItemCategory are mandatory
				var aCustomClearingStatus = oSelectionVariant.getValue("CustomClearingStatus");
				if (aCustomClearingStatus && aCustomClearingStatus[0].Low) {
					oSelectionVariantDelta.addParameter("CustomClearingStatus", aCustomClearingStatus[0].Low);
				} else {
					oSelectionVariantDelta.addParameter("CustomClearingStatus", this.getClearingStatusDefault());
				}
				var aDueItemCategory = oSelectionVariant.getValue("DueItemCategory");
				if (aDueItemCategory && aDueItemCategory[0].Low) {
					oSelectionVariantDelta.addParameter("DueItemCategory", aDueItemCategory[0].Low);
				} else {
					oSelectionVariantDelta.addParameter("DueItemCategory", JSON.stringify(this.getItemTypeDefault()));
				}
				// set the new filter, since it can be changed by the defaults
				var bOverwriteFilter = false;
				var bSetVisibleInFilterBar = false;
				this.setSmartFilterBarFilterData(oSelectionVariantDelta.toJSONString(), bOverwriteFilter, bSetVisibleInFilterBar);
			},
			
			onBeforeVariantSave: function(oEvent) {
				/*
				 * When the app is started, the VariantManagement of the SmartFilterBar saves the initial state in the STANDARD (=default) variant and
				 * therefore this event handler is called. We do not need to store the inner app state in this case, because it is the initial state. Only
				 * for variants, saved by the user, storeForBackNavigation must be called.
				 */
				if (oEvent.getParameter("context") !== "STANDARD") {
					if (this.oNavigationController) {
						this.oNavigationController.storeForBackNavigation(); // store local state for back navigation
					}
				}
			},
			
			onBeforeViewRendering: function() {
				var sCozyClass = "sapUiSizeCozy";
				var sCompactClass = "sapUiSizeCompact";
				var sCondensedClass = "sapUiSizeCondensed";
				if (jQuery(document.body).hasClass(sCompactClass) || this.oComponent.getContentDensityClass() === sCompactClass) {
					this.oSmartTable.addStyleClass(sCondensedClass);
				} else if (jQuery(document.body).hasClass(sCozyClass) || this.oComponent.getContentDensityClass() === sCozyClass) {
					this.oSmartTable.addStyleClass(sCozyClass);
				}
			},
			
			onInitSmartFilterBar: function() {
				
				this.oCustomData = {
					_bItemsLoaded: false,
					oAbstractController: this,
					
					getItemsLoaded: function() {
						return this._bItemsLoaded;
					},
					setItemsLoaded: function(bLoaded) {
						this._bItemsLoaded = bLoaded;
					},
					getVisibleInFilterBar: function(oSelectionVariant) {
						/*
						 * We want to restore not only the filter values in the FilterBar after a back navigation, but also the visibility
						 * of the fields in the FilterBar. Thus, we have to store the visibleInFilterBar properties of the fields, which
						 * 1) are visible in the FilterBar,
						 * 2) are included in the current selection variant (can be hidden),
						 * 3) which are special, i.e., those fields (KeyDate, ClearingDate, PostingDate), whose visibility is controlled
						 *    by the CustomClearingStatus, in order to be able to restore the current settings (even for currently not
						 *    visible fields), when the CustomClearingStatus is switched after a back navigation.
						*/
						var mVisibleInFilterBar = {}, i;
						var aAllFilterItems = this.oAbstractController.oSmartFilterBar.getAllFilterItems();
						for(i = 0; i < aAllFilterItems.length; i++){
							// There is no API to get only the fields, which are visible in the FilterBar, thus we have to loop at all items
							// and check if the item is visible.
							if(aAllFilterItems[i].getVisibleInFilterBar()){
								mVisibleInFilterBar[aAllFilterItems[i].getName()] = true;
							}
						}
						var aProperties = oSelectionVariant.getParameterNames().concat(oSelectionVariant.getSelectOptionsPropertyNames());
						for(i = 0; i < aProperties.length; i++){
							// Add hidden fields, which are included in the current selection variant. (Visible fields are already processed in step 1.)
							if(!this.oAbstractController.oSmartFilterBar.determineFilterItemByName(aProperties[i]).getVisibleInFilterBar()){
								mVisibleInFilterBar[aProperties[i]] = false;
							}
						}
						// Posting Key
						this.oAbstractController.oSmartFilterBar.determineFilterItemByName("PostingKey").setVisibleInFilterBar();						
						// Add the three special fields, if not yet included in the list
						if (mVisibleInFilterBar.KeyDate === undefined){
							mVisibleInFilterBar.KeyDate = this.oAbstractController.oSmartFilterBar.determineFilterItemByName("KeyDate").getVisibleInFilterBar();
						}
						if (mVisibleInFilterBar.ClearingDate === undefined){
							mVisibleInFilterBar.ClearingDate = this.oAbstractController.oSmartFilterBar.determineFilterItemByName("ClearingDate").getVisibleInFilterBar();
						}
						if (mVisibleInFilterBar.PostingDate === undefined){
							mVisibleInFilterBar.PostingDate = this.oAbstractController.oSmartFilterBar.determineFilterItemByName("PostingDate").getVisibleInFilterBar();
						}
						return mVisibleInFilterBar;
					},
					setVisibleInFilterBar: function(mVisibleInFilterBar) {
						// restore the visibleInFilterBar properties of the fields, which are included in the saved sap-iapp-state
						// (relevant only in case of "storeForBackNavigation")
						for(var sKey in mVisibleInFilterBar){
							this.oAbstractController.oSmartFilterBar.determineFilterItemByName(sKey).setVisibleInFilterBar(mVisibleInFilterBar[sKey]);
						}
					}
					
				};
				
				this.oCustomFields = {
					oClearingStatusControl: this.byId(this.sPrefix + ".CustomSelectClearingStatus"),
					oItemTypeControl: this.byId(this.sPrefix + ".CustomMultiComboBoxDueItemCategory"),
					oAbstractController: this,
					// Posting Key
					bPostingKeyBinded: true,
					getPostingKeyBinded: function() {
						return this.bPostingKeyBinded;
					},
					setPostingKeyBinded: function(bPostingKeyBinded) {
						this.bPostingKeyBinded= bPostingKeyBinded;
					},					
					
					getClearingStatus: function() {
						return this.oClearingStatusControl.getSelectedKey();
					},
					setClearingStatus: function(sClearingStatus, bSetVisibleInFilterBar) {
						// validate clearing status, set default if no valid value is provided
						var rClearingStatus = new RegExp("^[OCA]$");
						if (!rClearingStatus.exec(sClearingStatus)) {
							sClearingStatus = this.oAbstractController.getClearingStatusDefault();
						}
						this.oClearingStatusControl.setSelectedKey(sClearingStatus);
						
						// calculate visibility of the dependent fields
						var oView = this.oAbstractController.oView;
						var sPrefix = this.oAbstractController.sPrefix;
						var mVisibilitySettings = {};
						switch (sClearingStatus) {
							case "O":
								mVisibilitySettings = {
								                       KeyDate: true,
								                       ClearingDate: false,
								                       PostingDate: false
								};
								break;
							case "C":
								mVisibilitySettings = {
								                       KeyDate: true,
								                       ClearingDate: true,
								                       PostingDate: false
								};
								break;
							case "A":
								mVisibilitySettings = {
								                       KeyDate: false,
								                       ClearingDate: false,
								                       PostingDate: true
								};
								break;
						}
						













						for (var sKey in mVisibilitySettings) {
							oView.byId(sPrefix + ".Date" + sKey).setVisible(mVisibilitySettings[sKey]);
							if (bSetVisibleInFilterBar) {
								


								this.oAbstractController.oSmartFilterBar.determineFilterItemByName(sKey).setVisibleInFilterBar(mVisibilitySettings[sKey]);
							}							
						}
					},
					getItemType: function() {
						return this.oItemTypeControl.getSelectedKeys();
					},
					setItemType: function(aItemType) {
						var oDependentItem = this.oItemTypeControl.getItemByKey(this.oAbstractController.sCustomerVendorItemTypeKey);
						var bHasBasicItemType = false, i;
						
						// dependent item can only be selected together with a basic item. check that selected keys do not contain a dependend item only
						for (i = 0; i < aItemType.length; i++) {
							if (aItemType[i] !== this.oAbstractController.sCustomerVendorItemTypeKey) {
								bHasBasicItemType = true;
								break;
							}
						}
						
						if (bHasBasicItemType) {
							oDependentItem.setEnabled(true);
						} else {
							// make sure that the dependent item is deselected, otherwise it would not be displayed but still used as filter
							this.oItemTypeControl.removeSelectedItem(oDependentItem);
							oDependentItem.setEnabled(false);
							
							// remove dependent item code ("C" or "V") from selected item types
							// use jQuery over indexOf for better handling of invalid data types
							i = jQuery.inArray(this.oAbstractController.sCustomerVendorItemTypeKey, aItemType);
							if (i !== -1) {
								aItemType.splice(i, 1);
							}
						}
						
						// custom property hasValue is evaluated by the filter bar to show the correct amount of filters set
						if (aItemType.length === 0) {
							this.oItemTypeControl.data("hasValue", false);
						} else {
							this.oItemTypeControl.data("hasValue", true);
						}
						
						// validate item type, set default if no valid value is provided
						var bInvalid = false;
						if (jQuery.isArray(aItemType)) {
							if (aItemType.length > 0) {
								var sItemTypeKeys = this.oItemTypeControl.getKeys().toString().replace(/,/g, "");
								var rItemType = new RegExp("^[" + sItemTypeKeys + "]$");
								for (i = 0; i < aItemType.length; i++) {
									if (!rItemType.exec(aItemType[i])) {
										bInvalid = true;
										break;
									}
								}
							} // remark: do not set a default if aItemType = []
						} else {
							bInvalid = true;
						}
						if (bInvalid) {
							aItemType = this.oAbstractController.getItemTypeDefault();
						}
						this.oItemTypeControl.setSelectedKeys(aItemType);
						this.oItemTypeControl.fireChange(); // to take over hasValue custom control (= update filter counter)
					},
					enrichCustomFilters: function(aFilters) {
						var sStatus = this.getClearingStatus();
						var aType = this.getItemType();
						
						// XAUGP (Open, Cleared or All Items)
						switch (sStatus) {
							case "O":
								aFilters.push(new Filter("IsCleared", FilterOperator.EQ, " "));
								break;
							case "C":
								aFilters.push(new Filter("IsCleared", FilterOperator.EQ, "X"));
								break;
							case "A":
								// No filter necessary
								// Posting Key
								if (this.getPostingKeyBinded()) {
									aFilters.push(new Filter("PostingKey", FilterOperator.EQ, "21"));
									aFilters.push(new Filter("PostingKey", FilterOperator.EQ, "22"));
									aFilters.push(new Filter("PostingKey", FilterOperator.EQ, "24"));								
									aFilters.push(new Filter("PostingKey", FilterOperator.EQ, "31"));
									aFilters.push(new Filter("PostingKey", FilterOperator.EQ, "32"));								
									aFilters.push(new Filter("PostingKey", FilterOperator.EQ, "34"));																
									this.setPostingKeyBinded(false);
								}
								break;
							default:
								jQuery.sap.log.error("Wrong item status: " + sStatus);
								return;
						}
						
						// Set the item type filter dependent on the use case
						if (aType === null || aType.length < 1) {
							MessageToast.show(this.oAbstractController.oi18nLib.getText("TYPE_REQUIRED"));
							return;
						}
						for (var i = 0; i < aType.length; i++) {
							aFilters.push(new Filter("DueItemCategory", FilterOperator.EQ, aType[i]));
						}
					}
				};
				
				this.setSmartFilterBarDefaults();
			},
			
			onListFilterChange: function(oEvent) {
				// IM 0120031469 0000656513 2014: cell filter can not determine the right formatter. Within our application we can identify the
				// appropriate
				// formatter manually
				var oCol = oEvent.getParameter("column");
				var oValue = oEvent.getParameter("value");
				if (typeof oValue !== "string" && oCol.getFilterType() && oCol.getFilterType().getMetadata().getName() === "sap.ui.model.type.Date") {
					// idea is that this code is only exectuted if CellFilter is used
					// typeof oValue !== "string": typeof oValue will be string if value was entered in column filter bar by user manually (no cell
					// filter)
					// oCol.getFilterType().getMetadata().getName() === ...: all our Date columns are using a sap.ui.model.type.Date formatter
					var sFormattedValue = oCol.getTemplate().getBindingInfo("text").formatter(oValue);
					this.filter(oCol, sFormattedValue);
					oEvent.preventDefault();
				}
			},
			
			onRowSelectionChange: function(oEvent) {
				var bSelectAll = oEvent.getParameter("selectAll") || false;
				if (bSelectAll) {
					this.handleSelectAll();
				}
				var aSelectedIndices = this.oTable.getSelectedIndices();
				this.setSelectedKeysByTableRowIndices(aSelectedIndices);
				this.updateButtonBehavior(aSelectedIndices);
			},
			
			handleSelectAll: function() {
				



























				
				if (this.isTableGrouped()) {
					// should not occur, because SelectAll should be disabled if the table is grouped
					jQuery.sap.log.error("AbstractController.js: Table is grouped, but 'SelectAll' is active.");
					return;
				}
				var aSelectedIndices = this.oTable.getSelectedIndices();
				var iSelectedIndices = aSelectedIndices.length;
				var iTotalNumberOfSelectableItems = this.oTable.getTotalSize();
				var iLoadedItems = this.oTable.getVisibleRowCount() + this.oTable.getThreshold() - 1;
				var iMaxSelectableItems = Math.min(iTotalNumberOfSelectableItems, this.MAX_NUMBER_OF_ITEMS, iLoadedItems);
				
				// if necessary, enhance the selection up to the maximum number of allowed items
				if (iSelectedIndices < iTotalNumberOfSelectableItems) {
					this.enhanceSelectionAsFarAsPossible(iMaxSelectableItems);
				}
				// re-read the selected indices, because additional items could have been added by the previous function call
				aSelectedIndices = this.oTable.getSelectedIndices();
				iSelectedIndices = aSelectedIndices.length;
				if (iSelectedIndices > iMaxSelectableItems) {
					// ensure that not more than the maximum number of items are selected
					iSelectedIndices = iMaxSelectableItems;
				}
				if (iTotalNumberOfSelectableItems > iSelectedIndices) {
					// still not all items selected => set the selection interval and inform the user that not all items have been selected
					var iIndexHigh = aSelectedIndices[iSelectedIndices - 1];
					this.setRestrictedSelectionAndShowMessage(iIndexHigh, iSelectedIndices);
				}
			},
			
			enhanceSelectionAsFarAsPossible: function(iMaxSelectableItems) {
				/*
				 Items, which have been already loaded, but were not yet visible on the UI, can be added to the selection,
				 until the maximum number of selectable items is reached.
				 */
				var iIndexOfItem = 0;
				var oContext = {};
				while (iIndexOfItem < iMaxSelectableItems && oContext !== undefined) {
					/*
					 getContextByIndex() returns 'undefined' if the row was not yet loaded.
					 We don't want to load additional items due to performace reasons.
					 Accessing the context includes this item in the list of selected indices.
					 */
					oContext = this.oTable.getContextByIndex(iIndexOfItem);
					iIndexOfItem++;
				}
			},
			
			setRestrictedSelectionAndShowMessage: function(iIndexHigh, iSelectedIndices) {
				/*
				 The user has selected "All Items" on the UI, but technically not all items could actually be selected.
				 The restricted selection (from index 0 to iIndexHigh) is set and the user is informed via a message dialog
				 about this restriction. The user then can decide whether to keep or remove the selection.
				 */
				this.oTable.detachRowSelectionChange(this.onRowSelectionChange, this);
				this.oTable.setSelectionInterval(0, iIndexHigh);
				this.oTable.attachRowSelectionChange(this.onRowSelectionChange, this);
				var oController = this;
				var sActionKeep = this.oi18nLib.getText("ACTION_KEEP");
				var sActionRemove = this.oi18nLib.getText("ACTION_REMOVE");
				MessageBox.show(this.oi18nLib.getText("NOT_ALL_ITEMS_SELECTED", iSelectedIndices), {
					icon: MessageBox.Icon.INFORMATION,
					title: this.oi18nLib.getText("TITLE_INFORMATION"),
					actions: [sActionKeep, sActionRemove],
					onClose: function(sAction) {
						if (sAction === sActionRemove) {
							// Do not detach the RowSelectionChange event handler before the clearSelection() call.
							// The button behaviour has to be updated, thus, the event handler must be called.
							oController.oTable.clearSelection();
						}
					}
				});
			},
			
			isTableGrouped: function() {
				return this.oTable.getGroupedColumns().length > 0;
			},
			
			onAfterTableVariantApply: function() {
				this.manageSelectAllAvailability();
			},
			
			onTableGrouped: function(){
				this.manageSelectAllAvailability();
			},
			
			manageSelectAllAvailability: function() {
				// SelectAll must be disabled if the table is grouped, because there are no public UI5 APIs
				// which we can use to enhance the selection properly up to our threshold for a grouped table.
				var bSelectAllEnabled = !this.isTableGrouped();
				this.oTable.setEnableSelectAll(bSelectAllEnabled);
			},
			
			onAssignedFiltersChanged: function(oEvent) {
				var oFilterText = this.byId(this.sPrefix + ".FilterText");
				
				// If this event is fired before the onInit event of the View, the property
				// this.SmartFilterBar won't be set. Therefore we retrieve the SmartFilterBar
				// by Id instead
				var oSmartFilterBar = this.byId(this.sPrefix + ".SmartFilterBar");
				oFilterText.setText(oSmartFilterBar.retrieveFiltersWithValuesAsText());
			},
		
			onToggleHeaderPressed: function(oEvent) {
				var oPageModel = this.getView().getModel("page");
				oPageModel.setProperty("/headerExpanded", !oPageModel.getProperty("/headerExpanded"));
			},
			
			formatToggleButtonText: function (bValue){
				return bValue ? this.oi18nLib.getText("HIDE_FILTERS") : this.oi18nLib.getText("SHOW_FILTERS");
			},	

			onBeforeRebindTable: function(oEvent) {
				// table filters must be adjusted according to the current values of the custom controls
				this.oCustomFields.enrichCustomFilters(oEvent.getParameter("bindingParams").filters);
				
				this.oCustomData.setItemsLoaded(true); // remember that search was already processed
				this.oNavigationController.storeForBackNavigation(); // store local state for back navigation
				
				this.oTable.clearSelection();
				this.updateButtonBehavior([]);
			},
			
			onClearingStatusChange: function(oEvent) {
				var oSelectionVariant = new CentralLib.nav.SelectionVariant(this.oSmartFilterBar.getDataSuiteFormat());
				var sClearingStatus = oEvent.getSource().getSelectedKey();
				oSelectionVariant.addParameter("CustomClearingStatus", sClearingStatus);
				oSelectionVariant = this.setDateFilterDefaults(oSelectionVariant, sClearingStatus);
				var sSelectionVariant = oSelectionVariant.toJSONString();
				
				var bOverwriteFilter = true;
				var bSetVisibleInFilterBar = true;
				this.setSmartFilterBarFilterData(sSelectionVariant, bOverwriteFilter, bSetVisibleInFilterBar);
			},
				
			onTypeSelectionChange: function(oEvent, sItemKey) {
				var oSelectionVariant = new CentralLib.nav.SelectionVariant();
				var aDueItemCategories = oEvent.getSource().getSelectedKeys();
				oSelectionVariant.addParameter("DueItemCategory", JSON.stringify(aDueItemCategories));
				var sClearingStatus = this.oCustomFields.oClearingStatusControl.getSelectedKey();
				oSelectionVariant.addParameter("CustomClearingStatus", sClearingStatus);
				var sSelectionVariant = oSelectionVariant.toJSONString();
				
				var bOverwriteFilter = false;
				var bSetVisibleInFilterBar = false;
				this.setSmartFilterBarFilterData(sSelectionVariant, bOverwriteFilter, bSetVisibleInFilterBar);
			},
			
			navigateToCreateManualPayment: function(oParams) {
				this.oNavigationController.navigateToCreateManualPayment(oParams);
			},
			
			setSmartFilterBarFilterData: function(sFilterData, bOverwriteFilter, bSetVisibleInFilterBar) {
				var oSelectionVariant = new CentralLib.nav.SelectionVariant(sFilterData);
				
				// set key in "Item Type" custom control
				var aDueItemCategory = oSelectionVariant.getValue("DueItemCategory");
				if (aDueItemCategory && aDueItemCategory.length > 0) {
					var aItemtype = [];
					try {
						aItemtype = JSON.parse(aDueItemCategory[0].Low);
					} catch (e) {
						aItemtype.push(aDueItemCategory[0].Low);
					}
					this.oCustomFields.setItemType(aItemtype);
					
					// update selection variant as setItemType() may have removed invalid dependent type
					// also remove SelectOption which may have been set by inbound navigation
					oSelectionVariant.removeSelectOption("DueItemCategory");
					oSelectionVariant.removeParameter("DueItemCategory");
					oSelectionVariant.addParameter("DueItemCategory", JSON.stringify(this.oCustomFields.getItemType()));
					sFilterData = oSelectionVariant.toJSONString();
				}
				
				this.oSmartFilterBar.setDataSuiteFormat(sFilterData, bOverwriteFilter);
				
				// Set key in "Status" custom control, after(!) the selection variant was set, because the
				// setDataSuiteFormat(...) does not set only the filter data, but also sets the visibility
				// according to the variant, which is also included in the selection variant.
				var aCustomClearingStatus = oSelectionVariant.getValue("CustomClearingStatus");
				var sClearingStatus = "";
				if (aCustomClearingStatus && aCustomClearingStatus.length > 0) {
					sClearingStatus = aCustomClearingStatus[0].Low;
				}
				this.oCustomFields.setClearingStatus(sClearingStatus, bSetVisibleInFilterBar);
			},
			
			setDateFilterDefaults: function(oSelectionVariant, sClearingStatus){
				switch (sClearingStatus) {
					case "O": // open items should always have a key date set
						oSelectionVariant.addParameter("KeyDate", this.getKeyDateDefault());
						break;
					case "C": // cleared items should not have a key date set
						oSelectionVariant.removeParameter("KeyDate");
						var oClearingDate = this.getClearingDateDefault();
						oSelectionVariant.removeSelectOption("ClearingDate");
						oSelectionVariant.addSelectOption("ClearingDate", "I", oClearingDate.sOption, oClearingDate.sLow, oClearingDate.sHigh);
						break;
					case "A": // all items should always have a posting date set
						var oPostingDate = this.getPostingDateDefault();
						oSelectionVariant.removeSelectOption("PostingDate");
						oSelectionVariant.addSelectOption("PostingDate", "I", oPostingDate.sOption, oPostingDate.sLow, oPostingDate.sHigh);
						// Posting Key
						oSelectionVariant.removeSelectOption("PostingKey");
						oSelectionVariant.addSelectOption("PostingKey", "I", "EQ", '21');							
						oSelectionVariant.addSelectOption("PostingKey", "I", "EQ", '22');
						oSelectionVariant.addSelectOption("PostingKey", "I", "EQ", '24');							
						oSelectionVariant.addSelectOption("PostingKey", "I", "EQ", '31');							
						oSelectionVariant.addSelectOption("PostingKey", "I", "EQ", '32');
						oSelectionVariant.addSelectOption("PostingKey", "I", "EQ", '34');																
						break;
				}
				return oSelectionVariant;
			},
			
			setSmartFilterBarDefaults: function(sClearingStatus) {
				/*
				 * Problem: The KeyDate default depends on the ClearingStatus. Thus, the user of this function can provide
				 * the ClearingStatus, if known, in order to set the right KeyDate default. Example: 'Cleared Items' are requested
				 * by an incoming navigation, but no KeyDate is specified. Then, we don't set the KeyDate to 'today', because this
				 * is only the default in case of 'Open Items'. The default for 'Cleared Items' is 'initial'.
				 */
				
				// The ClearingStatus must be either "O", "C" or "A". Default is "O".
				if(!/^[OCA]$/.test(sClearingStatus)){
					sClearingStatus = this.getClearingStatusDefault();
				}
				var oSelectionVariant = new CentralLib.nav.SelectionVariant();
				oSelectionVariant.addParameter("CustomClearingStatus", sClearingStatus);
				oSelectionVariant.addParameter("DueItemCategory", JSON.stringify(this.getItemTypeDefault()));
				oSelectionVariant = this.setDateFilterDefaults(oSelectionVariant, sClearingStatus);
				
				var bOverwriteFilter = true;
				var bSetVisibleInFilterBar = false;
				this.setSmartFilterBarFilterData(oSelectionVariant.toJSONString(), bOverwriteFilter, bSetVisibleInFilterBar);
			},
			
			getVisibleSelectionsWithDefaults: function() {
				// We need a list of all selection fields in the SmartFilterBar for which defaults are defined
				// (see method setSmartFilterBarDefaults) and which are currently visible.
				// This is needed by _getBackNavigationParameters in the NavigationController.
				var aVisibleFields = [];
				if (this.oView.byId(this.sPrefix + ".DateKeyDate").getVisible()) {
					aVisibleFields.push("KeyDate");
				}
				if (this.oView.byId(this.sPrefix + ".DatePostingDate").getVisible()) {
					aVisibleFields.push("PostingDate");
				}
				return aVisibleFields;
			},
			
			getKeyDateDefault: function() {
				var oToday = new Date();
				return oToday.toJSON();
			},
			
			getPostingDateDefault: function() {
//				var oToday = new Date();
//				var oJan1st = new Date("01/01/00");
//				oJan1st.setYear(oToday.getFullYear());
				var o12MonthsToDateTo = new Date();
				var o12MonthsToDateFrom = new Date(parseInt(o12MonthsToDateTo.getFullYear()) - 1,parseInt(o12MonthsToDateTo.getMonth()),1,0,0,0,0); 				
				return {
					sOption: "BT",
//					sLow: oJan1st.toJSON(),
//					sHigh: oToday.toJSON()
					sLow: o12MonthsToDateFrom.toJSON(),
					sHigh: o12MonthsToDateTo.toJSON()
				};
			},
			
			getClearingDateDefault: function() {
				return {
					sOption: "EQ",
					sLow: "",
					sHigh: null
				};
			},
			
			getClearingStatusDefault: function() {
//				return "O";
				return "A";				
			},
			
			getItemTypeDefault: function() {
				return [
					"N"
				];
			},
			
			setSelectedKeysByTableRowIndices: function(aRowIndices) {
				this.aSelectedKeys = [];
				var i = 0, sKey = "";
				for (i = 0; i < aRowIndices.length; i++) {
					var oContext = this.oTable.getContextByIndex(aRowIndices[i]);
					if (oContext && oContext.getProperty && oContext.getObject) {
						sKey = this.createKey({
							"AccountingDocument": oContext.getProperty("AccountingDocument"),
							"AccountingDocumentItem": oContext.getProperty("AccountingDocumentItem"),
							"FiscalYear": oContext.getProperty("FiscalYear"),
							"CompanyCode": oContext.getProperty("CompanyCode"),
							"etag": oContext.getObject().__metadata.etag
						});
						if (typeof sKey !== "undefined") { // sKey is only defined properly, if all key fields are provided
							this.aSelectedKeys.push(sKey);
						}
					} else {
						jQuery.sap.log.error("AbstractController.js: oContext of index " + aRowIndices[i] + " is not defined");
					}
				}
			},
			
			updateButtonBehavior: function(aSelectedIndices) {
				var oToolbar = this.oView.byId(this.sPrefix + ".OverflowToolbar");
				aSelectedIndices = aSelectedIndices || this.oTable.getSelectedIndices();
				
				var aControls = oToolbar.getControlsByFieldGroupId("enableIfAtLeastOneRowSelected");
				var bEnable = aSelectedIndices.length > 0 && !this.oTable.getShowOverlay();
				for (var i = 0; i < aControls.length; i++) {
					aControls[i].setEnabled(bEnable);
				}

				aControls = oToolbar.getControlsByFieldGroupId("enableIfExactlyOneRowSelected");
				bEnable = aSelectedIndices.length === 1 && !this.oTable.getShowOverlay();
				for (i = 0; i < aControls.length; i++) {
					aControls[i].setEnabled(bEnable);
				}

				if (this.oExtensionHelper) {
					this.oExtensionHelper.setEnableExtensionButtons();
				}
			},
			
			setGroupHeaderFormatter: function() {
				this.byId(this.sPrefix + ".ColumnClearingStatusIcon").setGroupHeaderFormatter(Formatter.formatClearingStatusTooltip);
				this.byId(this.sPrefix + ".ColumnDueNetSymbol").setGroupHeaderFormatter(Formatter.formatDueNetSymbolTooltip);
				this.byId(this.sPrefix + ".ColumnCashDateDueNetSymbol").setGroupHeaderFormatter(Formatter.formatDueNetSymbolTooltip);
				this.byId(this.sPrefix + ".ColumnDocumentDate").setGroupHeaderFormatter(Formatter.formatDate);
				this.byId(this.sPrefix + ".ColumnClearingDate").setGroupHeaderFormatter(Formatter.formatDate);
			},

			openPopover: function(oEvent, sSelfNavigationText) {
				// This event handler is called after oParameters.open(), which was triggered by onBeforePopoverOpens.
				var oEventParameters = oEvent.getParameters();
				
				if (oEventParameters.semanticObject === this.sOwnSemanticObject) {
					var oDataForm = this.oForm;
				} else if (oEventParameters.semanticObject === "DisputeCase") {
					oDataForm = this.oForm;
				}
				var aActions = this.modifyPopoverActions(oEventParameters, oEventParameters.semanticObject, sSelfNavigationText);
				oEventParameters.show(undefined, aActions, oDataForm); // opens the popover
			},

			createPopoverContent: function(oEvent, sAddressDataPath) {
				var oParameters = oEvent.getParameters();
				var sSelectionVariant = this.oSmartFilterBar.getDataSuiteFormat();
				// internally, oParameters.open() is called, which fires the event navigationTargetsObtained
				this.processBeforeSmartLinkPopoverOpens(oParameters, sSelectionVariant);
				
				if (oParameters.semanticObject === this.sOwnSemanticObject) {
					this.createAddressForm(sAddressDataPath);
				} else if (oParameters.semanticObject === "DisputeCase") {
					var oSemanticAttributes = oParameters.semanticAttributes;
					this.createDisputeCaseDisplayForm(oSemanticAttributes);
				}
			},
			
			createDisputeCaseDisplayForm: function (oSemanticAttributes) {
				var sItemDataPath = "/Items";
				var oFilter1 = this.createFilterObject("AccountingDocument", sap.ui.model.FilterOperator.EQ, oSemanticAttributes.AccountingDocument,"");
				var oFilter2 = this.createFilterObject("AccountingDocumentItem", sap.ui.model.FilterOperator.EQ, oSemanticAttributes.AccountingDocumentItem,"");
				var oFilter3 = this.createFilterObject("CompanyCode", sap.ui.model.FilterOperator.EQ, oSemanticAttributes.CompanyCode, "");
				var oFilter4 = this.createFilterObject("FiscalYear", sap.ui.model.FilterOperator.EQ, oSemanticAttributes.FiscalYear, "");
				
				this.oForm = new SimpleForm({
					maxContainerCols: 1
				});
				this.oForm.addContent(new Title({
					text: this.oi18nLib.getText("POPOVER_DISPUTE"),
					level: sap.ui.core.TitleLevel.H2
				}));
				var oDisputeDetails = new Text();
				oDisputeDetails.setText(Formatter.formatAddress("/////")); // reserve 5 text lines
				oDisputeDetails.setBusy(true);
				this.oForm.addContent(oDisputeDetails);
				var oController = this;
				
				var mParameters = {
					filters: [oFilter1,oFilter2,oFilter3,oFilter4],
					urlParameters: { 
						$select: ["DisputeCasePriority","DisputeCasePriorityName","DisputeCaseReason","DisputeCaseReasonName","DisputeCaseStatus","DisputeCaseStatusName","DisputeCaseProcessorFullName","DisputeCaseTitle"]
						},
					success: function(oData){
						if (oData.results[0]) {
							var sText = oController.fillDisputeCasePopoverContent(oData);
							oDisputeDetails.setText(sText);
						}
						oDisputeDetails.setBusy(false);
					},
					error: function(oError){
						oDisputeDetails.setText(oController.oi18nLib.getText("MSG_DISPUTE_DATA_NOT_READ"));
						oDisputeDetails.setBusy(false);
					}
				};
				this.oModel.read(sItemDataPath, mParameters);
			},
			
			fillDisputeCasePopoverContent: function(oData) {
				var sText = "";
				if (oData.results[0].DisputeCasePriorityName !== "") {
					sText = this.oi18nLib.getText("DISPUTE_CASE_PRIORITY", oData.results[0].DisputeCasePriorityName) + "/";
				}
				if (oData.results[0].DisputeCaseStatusName !== "") {
					sText = sText + this.oi18nLib.getText("DISPUTE_CASE_STATUS", oData.results[0].DisputeCaseStatusName) + "/";
				}
				if (oData.results[0].DisputeCaseReasonName !== "") {
					sText = sText + this.oi18nLib.getText("DISPUTE_CASE_REASON", oData.results[0].DisputeCaseReasonName) + "/";
				}
				if (oData.results[0].DisputeCaseProcessorFullName !== "") {
					sText = sText + this.oi18nLib.getText("DISPUTE_CASE_PROCESSOR", oData.results[0].DisputeCaseProcessorFullName) + "/";
				}
				if (oData.results[0].DisputeCaseTitle !== "") {
					sText = sText + this.oi18nLib.getText("DISPUTE_CASE_TITLE", oData.results[0].DisputeCaseTitle);
				}
				return (sText.split("/").join("\n"));
			},
			
			createFilterObject: function(sPath, sOperator, sValue1, sValue2) {
				return new sap.ui.model.Filter({
				    path: sPath,
				    operator: sOperator,
				    value1: sValue1,
				    value2: sValue2
				});
			},
			
			createAddressForm: function(sAddressDataPath) {
				this.oForm = new SimpleForm({
					maxContainerCols: 1
				});
				this.oForm.addContent(new Title({
					text: this.oi18nLib.getText("POPOVER_ADDRESS"),
					level: sap.ui.core.TitleLevel.H2
				}));
				var oAddressText = new Text();
				oAddressText.setText(Formatter.formatAddress("///")); // reserve 3 text lines
				oAddressText.setBusy(true);
				this.oForm.addContent(oAddressText);
				
				var mParameters = {
					success: function(oData){
						oAddressText.setText(Formatter.formatAddress(oData.Address));
						oAddressText.setBusy(false);
					},
					error: jQuery.proxy(function(){
						oAddressText.setText(this.oi18nLib.getText("MSG_ADDRESS_NOT_FOUND"));
						oAddressText.setBusy(false);
					}, this)
				};
					
				this.oModel.read(sAddressDataPath, mParameters);
			},

			onButtonPressedChangeDocument: function() {
				if (this.aSelectedKeys.length <= this.MAX_NUMBER_OF_ITEMS) {
					if (!this.oChangeDocumentsDialog) {
						this.oChangeDocumentsDialog = new ChangeDocuments(this.oView);
					}
					this.oChangeDocumentsDialog.getValueHelpsAndOpenDialog(
						jQuery.proxy(this.oChangeDocumentsDialog.open, this.oChangeDocumentsDialog));
				} else {
					MessageBox.information(this.oi18nLib.getText("NO_ITEM_CHANGE_LIMIT", this.MAX_NUMBER_OF_ITEMS));
				}
			},

			onButtonPressedDunningBlock: function() {
				if (this.aSelectedKeys.length <= this.MAX_NUMBER_OF_ITEMS) {
					if (!this.oBlockDunningDialog) {
						this.oBlockDunningDialog = new BlockItems(this.oView, this.BLOCK_ACTION_TYPE_DUN);
					}
					this.oBlockDunningDialog.getValueHelpsAndOpenDialog(
						jQuery.proxy(this.oBlockDunningDialog.open, this.oBlockDunningDialog));
				} else {
					MessageBox.information(this.oi18nLib.getText("NO_ITEM_CHANGE_LIMIT", this.MAX_NUMBER_OF_ITEMS));
				}
			},

			onButtonPressedPaymentBlock: function() {
				if (this.aSelectedKeys.length <= this.MAX_NUMBER_OF_ITEMS) {
					if (!this.oBlockPaymentDialog) {
						this.oBlockPaymentDialog = new BlockItems(this.oView, this.BLOCK_ACTION_TYPE_PMT);
					}
					this.oBlockPaymentDialog.getValueHelpsAndOpenDialog(
						jQuery.proxy(this.oBlockPaymentDialog.open, this.oBlockPaymentDialog));
				} else {
					MessageBox.information(this.oi18nLib.getText("NO_ITEM_CHANGE_LIMIT", this.MAX_NUMBER_OF_ITEMS));
				}
			},

			onButtonPressedDunningUnblock: function() {
				if (this.aSelectedKeys.length <= this.MAX_NUMBER_OF_ITEMS) {
					if (!this.oBlockDunningDialog) {
						this.oBlockDunningDialog = new BlockItems(this.oView, this.BLOCK_ACTION_TYPE_DUN);
					}
					this.oBlockDunningDialog.submitChanges(this.oBlockDunningDialog.UNBLOCK);
				} else {
					MessageBox.information(this.oi18nLib.getText("NO_ITEM_CHANGE_LIMIT", this.MAX_NUMBER_OF_ITEMS));
				}
			},

			onButtonPressedPaymentUnblock: function() {
				if (this.aSelectedKeys.length <= this.MAX_NUMBER_OF_ITEMS) {
					if (!this.oBlockPaymentDialog) {
						this.oBlockPaymentDialog = new BlockItems(this.oView, this.BLOCK_ACTION_TYPE_PMT);
					}
					this.oBlockPaymentDialog.submitChanges(this.oBlockPaymentDialog.UNBLOCK);
				} else {
					MessageBox.information(this.oi18nLib.getText("NO_ITEM_CHANGE_LIMIT", this.MAX_NUMBER_OF_ITEMS));
				}
			},

			sendCorrespondence: function(sAccountType, sAccountNumberType) {
				var oKey = this.getKey(this.aSelectedKeys[0]);
				var oParams = {
					CompanyCode: oKey.CompanyCode,
					DocumentNumber: oKey.AccountingDocument,
					FiscalYear: oKey.FiscalYear,
					AccountType: sAccountType
				};
				var iSelectedIndex = this.oTable.getSelectedIndices()[0];
				if (iSelectedIndex > -1) {
					// Get customer from context, if available (it is not available, if selected row is not among currently loaded items)
					var oContext = this.oTable.getContextByIndex(iSelectedIndex);
					oParams.AccountNumber = oContext.getProperty(sAccountNumberType);
				}
				
				this.oNavigationController.navigateToCreateCorrespondence(oParams);
			},
			
			onShareButtonPressed: function(oEvent) {
				if (!this.oShareActionSheetController) {
					this.oShareActionSheetController = new ShareActionSheetController(this);
				}
				this.oShareActionSheetController.openActionSheet(oEvent);
			},
			
			addExtensionButtons: function(oOptions) {
				if (!this.oExtensionHelper) {
					this.oExtensionHelper = new ExtensionHelper(this, this.oPageTitle); 
				}
				this.oExtensionHelper.addExtensionButtons(oOptions);
			}
			
		});
		return AbstractController;
	}, /* bExport= */true);