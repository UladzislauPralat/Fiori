/*
 * Copyright (C) 2009-2018 SAP SE or an SAP affiliate company. All rights reserved.
 */
sap.ui.define(["com/spinmaster/fin/ap/lineitems/display/view/AbstractController", "sap/fin/central/lib/nav/SelectionVariant", "sap/m/MessageBox",
	"sap/ui/core/BusyIndicator"
], function(A, S, M, B) {
	"use strict";
	var a = sap.fin.arp.lib.lineitems.controller.AbstractController.extend("com.spinmaster.fin.ap.lineitems.display.view.S1", {
		constructor: function() {
			A.apply(this, arguments);
			this.sLocalContainerKey = "fin.ap.lineitems";
			this.sPrefix = "com.spinmaster.fin.ap.lineitems.display";
			this.sIconPath = "sap-icon://Fiori5/F0712";
			this.sSchemaNamespace = "FAP_VENDOR_LINE_ITEMS_SRV";
			this.sOwnSemanticObject = "Supplier";
			this.sCustomerVendorItemTypeKey = "C";
			this.initDeferred = jQuery.Deferred();
		},
		onInit: function() {
			A.prototype.onInit.apply(this, arguments);
			this.setExtendedFooterOptions();
		},
		onExit: function() {
			this.cleanUpNavController();
		},
		onInitSmartFilterBar: function() {
			var c = this;
			this.initDeferred.done(function() {
				A.prototype.onInitSmartFilterBar.apply(c, arguments);
				c.checkForNavigation(jQuery.proxy(c.renameNavigationParameters, c));
			});
		},
		renameNavigationParameters: function(f) {
			var v = "Vendor";
			var V = "Supplier";
			var s = new S(f);
			s.renameParameter(v, V);
			s.renameSelectOption(v, V);
			f = s.toJSONString();
			return f;
		},
		onNavTargetsObtained: function(e) {
			this.openPopover(e, this.oi18n.getText("POPOVER_VLI_LINK"));
		},
		onBeforePopoverOpens: function(e) {
			var v = e.getParameters().semanticAttributes[this.sOwnSemanticObject];
			var s = "/Suppliers(SupplierId='" + encodeURIComponent(v) + "')";
			this.createPopoverContent(e, s);
		},
		onButtonPressedSendCorrespondence: function() {
			if (this.aSelectedKeys.length <= this.MAX_NUMBER_OF_ITEMS) {
				this.sendCorrespondence("K", "Supplier");
			} else {
				M.information(this.oi18nLib.getText("NO_ITEM_CHANGE_LIMIT", this.MAX_NUMBER_OF_ITEMS));
			}
		},
		onButtonPressedCreatePayment: function() {
			if (this.aSelectedKeys.length <= this.MAX_NUMBER_OF_ITEMS) {
				var k = [];
				for (var i = 0; i < this.aSelectedKeys.length; i++) {
					var K = [this.getKey(this.aSelectedKeys[i]).CompanyCode, this.getKey(this.aSelectedKeys[i]).AccountingDocument, this.getKey(this.aSelectedKeys[
						i]).FiscalYear, this.getKey(this.aSelectedKeys[i]).AccountingDocumentItem].join("#");
					k.push(K);
				}
				var p = "/CheckPaymentItems";
				var P = {
					urlParameters: {
						"keys": "'" + k.join("#") + "#'"
					},
					success: jQuery.proxy(this.createPaymentSuccess, this),
					error: function() {
						B.hide();
					}
				};
				B.show(this.BUSY_INDICATOR_DELAY);
				this.oModel.read(p, P);
			} else {
				M.information(this.oi18nLib.getText("NO_ITEM_CHANGE_LIMIT", this.MAX_NUMBER_OF_ITEMS));
			}
		},
		createPaymentSuccess: function(d) {
			B.hide();
			if (d.rv === "X") {
				var s = new S();
				for (var i = 0; i < this.aSelectedKeys.length; i++) {
					var k = this.getKey(this.aSelectedKeys[i]);
					var K = [k.AccountingDocument.toString(), k.FiscalYear.toString(), k.AccountingDocumentItem.toString(), k.CompanyCode.toString()]
						.join("|");
					s.addSelectOption("ConcatenatedAccountingDocumentKey", "I", "EQ", K);
				}
				var b = s.toJSONString();
				this.navigateToCreateManualPayment(b);
			}
		},
		onBeforeRendering: function() {
			this.onBeforeViewRendering();
		},
		setExtendedFooterOptions: function() {
			if (this.extHookModifyFooterOptions) {
				var o = this.extHookModifyFooterOptions({
					buttonList: []
				});
				if (o.buttonList && o.buttonList.length > 0) {
					this.addExtensionButtons(o);
				}
			}
		}
	});
	return a;
}, true);