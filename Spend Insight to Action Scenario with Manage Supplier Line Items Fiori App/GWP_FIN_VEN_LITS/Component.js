/*
 * Copyright (C) 2009-2018 SAP SE or an SAP affiliate company. All rights reserved.
 */
sap.ui.define(["sap/ui/core/UIComponent", "sap/ui/Device", "sap/fin/arp/lib/lineitems/util/ErrorHandler"], function(U, D, E) {
	"use strict";
	return U.extend("com.spinmaster.fin.ap.lineitems.display.Component", {
		metadata: {
			manifest: "json"
		},
		init: function() {
			U.prototype.init.apply(this, arguments);
			this.oErrorHandler = new E(this);
			this.getRouter().initialize();
		},
		createContent: function() {
			var r = U.prototype.createContent.apply(this, arguments);
			r.addStyleClass(this.getContentDensityClass());
			return r;
		},
		getContentDensityClass: function() {
			if (this._sContentDensityClass === undefined) {
				if (jQuery(document.body).hasClass("sapUiSizeCozy") || jQuery(document.body).hasClass("sapUiSizeCompact")) {
					this._sContentDensityClass = "";
				} else if (!D.support.touch) {
					this._sContentDensityClass = "sapUiSizeCompact";
				} else {
					this._sContentDensityClass = "sapUiSizeCozy";
				}
			}
			return this._sContentDensityClass;
		}
	});
});