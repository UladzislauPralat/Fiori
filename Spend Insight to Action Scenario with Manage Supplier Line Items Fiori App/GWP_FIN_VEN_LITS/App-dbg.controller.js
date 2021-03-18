/*
 * Copyright (C) 2009-2018 SAP SE or an SAP affiliate company. All rights reserved.
 */
sap.ui.define(["sap/fin/arp/lib/lineitems/controller/AbstractController"], 
	function (AbstractController) {
		"use strict";
		return AbstractController.extend("com.spinmaster.fin.ap.lineitems.display.App", {
			onInit : function () {
				// apply content density mode to root view
				this.getView().addStyleClass(this.getOwnerComponent().getContentDensityClass());
			}
	});
});