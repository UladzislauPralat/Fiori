class ZCL_ZFAR_CUSTOMER_LINE_MPC_EXT definition
  public
  inheriting from ZCL_ZFAR_CUSTOMER_LINE_MPC
  create public .

public section.

  methods DEFINE
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZFAR_CUSTOMER_LINE_MPC_EXT IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ZFAR_CUSTOMER_LINE_MPC_EXT->DEFINE
* +-------------------------------------------------------------------------------------------------+
* | [!CX!] /IWBEP/CX_MGW_MED_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD define.

  super->define( ).
  DATA(lo_entity_type) = model->get_entity_type( 'Item' ).
  lo_entity_type->set_semantic( /iwbep/if_ana_odata_types=>gcs_ana_odata_semantic_value-query-aggregate ).
*
  lo_entity_type->get_property( 'AmountType' )->/iwbep/if_mgw_odata_annotatabl~create_annotation(
    /iwbep/if_mgw_med_odata_types=>gc_sap_namespace )->add(
      iv_key = /iwbep/if_ana_odata_types=>gcs_ana_odata_annotation_key-aggregation_role
      iv_value = /iwbep/if_ana_odata_types=>gcs_ana_odata_annotation_value-dimension-dimension ).
  lo_entity_type->get_property( 'AgingGroup' )->/iwbep/if_mgw_odata_annotatabl~create_annotation(
    /iwbep/if_mgw_med_odata_types=>gc_sap_namespace )->add(
      iv_key = /iwbep/if_ana_odata_types=>gcs_ana_odata_annotation_key-aggregation_role
      iv_value = /iwbep/if_ana_odata_types=>gcs_ana_odata_annotation_value-dimension-dimension ).
   lo_entity_type->get_property( 'AmountInvoice' )->/iwbep/if_mgw_odata_annotatabl~create_annotation(
    /iwbep/if_mgw_med_odata_types=>gc_sap_namespace )->add(
      iv_key = /iwbep/if_ana_odata_types=>gcs_ana_odata_annotation_key-aggregation_role
      iv_value = /iwbep/if_ana_odata_types=>gcs_ana_odata_annotation_value-measure-measure ).
   lo_entity_type->get_property( 'AmountDeduction' )->/iwbep/if_mgw_odata_annotatabl~create_annotation(
    /iwbep/if_mgw_med_odata_types=>gc_sap_namespace )->add(
      iv_key = /iwbep/if_ana_odata_types=>gcs_ana_odata_annotation_key-aggregation_role
      iv_value = /iwbep/if_ana_odata_types=>gcs_ana_odata_annotation_value-measure-measure ).
   lo_entity_type->get_property( 'AmountCredit' )->/iwbep/if_mgw_odata_annotatabl~create_annotation(
    /iwbep/if_mgw_med_odata_types=>gc_sap_namespace )->add(
      iv_key = /iwbep/if_ana_odata_types=>gcs_ana_odata_annotation_key-aggregation_role
      iv_value = /iwbep/if_ana_odata_types=>gcs_ana_odata_annotation_value-measure-measure ).

ENDMETHOD.
ENDCLASS.