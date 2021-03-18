/*
 * Copyright (C) 2009-2018 SAP SE or an SAP affiliate company. All rights reserved.
 */
sap.ui.define(
	["sap/fin/arp/lib/lineitems/controller/AbstractController",
	"sap/fin/central/lib/nav/SelectionVariant",
	"sap/m/MessageBox",
	"sap/ui/core/BusyIndicator"],
	function(AbstractController, SelectionVariant, MessageBox, BusyIndicator){
		"use strict";

		var S1Controller = sap.fin.arp.lib.lineitems.controller.AbstractController.extend(
			"com.spinmaster.fin.ap.lineitems.display.view.S1", {
			/**
			 * @memberOf com.spinmaster.fin.ap.lineitems.display.view.S1.controller
			 */

			constructor: function() {
				AbstractController.apply(this, arguments);
				this.sLocalContainerKey = "fin.ap.lineitems";
				this.sPrefix = "com.spinmaster.fin.ap.lineitems.display";
				this.sIconPath = "sap-icon://Fiori5/F0712";
				this.sSchemaNamespace = "FAP_VENDOR_LINE_ITEMS_SRV";
				this.sOwnSemanticObject = "Supplier";
				this.sCustomerVendorItemTypeKey = "C";
				this.initDeferred = jQuery.Deferred();
			},

			onInit: function() {
				AbstractController.prototype.onInit.apply(this, arguments);
				this.setExtendedFooterOptions();
			},
			
			onExit: function() {
				this.cleanUpNavController();
			},

			onInitSmartFilterBar: function() {
				var oController = this;
				this.initDeferred.done(function(){
					AbstractController.prototype.onInitSmartFilterBar.apply(oController, arguments);
					oController.checkForNavigation(jQuery.proxy(oController.renameNavigationParameters, oController));
				});
			},

			renameNavigationParameters: function(sFilterData) {
				// In case of incoming navigation:
				// The "vendor/supplier" semantic object used to be called "Vendor". With the delivery 
				// of S/4H OP 1511 the name was changed to "Supplier". In order to still be able to 
				// support "old" links or saved tiles, we need a mapping.
				var sVendorPropertyOld = "Vendor";
				var sVendorPropertyNew = "Supplier";
				var oSelectionVariant = new SelectionVariant(sFilterData);
				oSelectionVariant.renameParameter(sVendorPropertyOld, sVendorPropertyNew);
				oSelectionVariant.renameSelectOption(sVendorPropertyOld, sVendorPropertyNew);
				sFilterData = oSelectionVariant.toJSONString();
				return sFilterData;
			},

			onNavTargetsObtained: function(oEvent) {
				this.openPopover(oEvent, this.oi18n.getText("POPOVER_VLI_LINK"));
			},
			
			onBeforePopoverOpens: function(oEvent) {
				// This event handler is called, when a smart link is clicked.
				var sVendor = oEvent.getParameters().semanticAttributes[this.sOwnSemanticObject];
				var sAddressDataPath = "/Suppliers(SupplierId='" + encodeURIComponent(sVendor) + "')";
				this.createPopoverContent(oEvent, sAddressDataPath);
			},

			onButtonPressedSendCorrespondence: function() {
				if (this.aSelectedKeys.length <= this.MAX_NUMBER_OF_ITEMS) {
					this.sendCorrespondence("K", "Supplier");
				} else {
					MessageBox.information(this.oi18nLib.getText("NO_ITEM_CHANGE_LIMIT", this.MAX_NUMBER_OF_ITEMS));
				}
			},

			onButtonPressedCreatePayment: function() {
				if (this.aSelectedKeys.length <= this.MAX_NUMBER_OF_ITEMS) {
					var aKeys = [];
					for (var i = 0; i < this.aSelectedKeys.length; i++) {
						var sKey = [
							this.getKey(this.aSelectedKeys[i]).CompanyCode,
							this.getKey(this.aSelectedKeys[i]).AccountingDocument,
							this.getKey(this.aSelectedKeys[i]).FiscalYear,
							this.getKey(this.aSelectedKeys[i]).AccountingDocumentItem
						].join("#");
						aKeys.push(sKey);
					}
					var sPath = "/CheckPaymentItems";
	
					var mParameters = {
						urlParameters: {"keys": "'" + aKeys.join("#") + "#'"},
						success: jQuery.proxy(this.createPaymentSuccess, this),
						error: function() {
							BusyIndicator.hide();
						}
					};
					
					BusyIndicator.show(this.BUSY_INDICATOR_DELAY);
					this.oModel.read(sPath, mParameters);
				} else {
					MessageBox.information(this.oi18nLib.getText("NO_ITEM_CHANGE_LIMIT", this.MAX_NUMBER_OF_ITEMS));
				}
			},

			createPaymentSuccess: function(oData) {
				BusyIndicator.hide();
				
				if (oData.rv === "X") {
					// The following format of sKey is discussed with the colleagues responsible for the "Create Manual Payment" app.
					// We need to pass a set of concatenated key values. The current navigation concept does not support this requirement.
					var oSelectionVariant = new SelectionVariant();
					for (var i = 0; i < this.aSelectedKeys.length; i++) {
						var oKey = this.getKey(this.aSelectedKeys[i]);
						var sKey = [
							oKey.AccountingDocument.toString(), 
							oKey.FiscalYear.toString(),
							oKey.AccountingDocumentItem.toString(), 
							oKey.CompanyCode.toString()
						].join("|");
						oSelectionVariant.addSelectOption("ConcatenatedAccountingDocumentKey", "I", "EQ", sKey);
					}
					var sSelectionVariant = oSelectionVariant.toJSONString();
					this.navigateToCreateManualPayment(sSelectionVariant);
				}
			},
			
			onBeforeRendering: function() {
				// The "onBeforeRendering" event handler must be defined in the S1.controller, not in the AbstractController.
				// The "this" variable has a different context, if onBeforeRendering is directly defined in the AbstractController.
				this.onBeforeViewRendering();
			},
			
			setExtendedFooterOptions: function(){
				/**
				 * @ControllerHook Allows modification of the footer area. Implement this hook if you wish to add new buttons to the footer bar. 
				 * The hook is called onInit when the footer options are defined.
				 * Example of adding a button in extHookModifyFooterOptions:
				 * 
				 * extHookModifyFooterOptions: function(oOptions) {
				 *	var fnOnBtnPressed = function() { 
				 *							this.oSmartFilterBar.search();
				 *						};
				 *
				 *	var fnCalcEnabled = function(oController) {
				 *							return oController.aSelectedKeys.length >= 1;
				 *						}; //optional function which returns true or false
				 *
				 *	var myButton = { sId: "myButton",
				 *					sI18nBtnTxt: "My Button",
				 *					bDisabled: false,
				 *					onBtnPressed: jQuery.proxy(fnOnBtnPressed,this),
				 *					calcEnabled: fnCalcEnabled
				 *					};
				 *
				 *	oOptions.buttonList.push(myButton);
				 *	return oOptions;
				 * }
				 * 
				 * @callback sap.ca.scfld.md.controller.BaseFullscreenController~extHookModifyFooterOptions
				 * @param {Object} oOptions: Object conatining the buttonList array
				 * @return {Object} oOptions: modified footer options in the same format as the parameter. Note that the return parameter must contain the complete object
				 */
				 
				if (this.extHookModifyFooterOptions) {
					var oOptions = this.extHookModifyFooterOptions({buttonList: []});
					if(oOptions.buttonList && oOptions.buttonList.length > 0){
						this.addExtensionButtons(oOptions);
					}
				}
			}

		});
		
		return S1Controller;
	}, /* bExport= */true);