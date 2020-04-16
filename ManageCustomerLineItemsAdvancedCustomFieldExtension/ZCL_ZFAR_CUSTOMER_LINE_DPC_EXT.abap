class ZCL_ZFAR_CUSTOMER_LINE_DPC_EXT definition
  public
  inheriting from ZCL_ZFAR_CUSTOMER_LINE_DPC
  create public .

public section.
protected section.

  methods ITEMSET_GET_ENTITYSET
    redefinition .
private section.

  methods IS_TOTAL
    importing
      !IS_REQUEST_DETAILS type /IWBEP/IF_MGW_CORE_SRV_RUNTIME=>TY_S_MGW_REQUEST_CONTEXT
      !IO_MODEL type ref to /IWBEP/IF_MGW_ODATA_FW_MODEL
    returning
      value(RV_IS_TOTAL) type ABAP_BOOL .
  methods ADD_SELECT_PROPERTIES
    importing
      !IT_TECH_FIELD_NAME type STRING_TABLE
      !IT_FIELD_NAME type STRING_TABLE
    changing
      !CS_REQUEST_DETAILS type /IWBEP/IF_MGW_CORE_SRV_RUNTIME=>TY_S_MGW_REQUEST_CONTEXT .
  methods GET_AMOUNT_TYPE
    importing
      !IS_ENTITYSET type CL_FAR_CUSTOMER_LINE_I_MPC=>TS_ITEM
    returning
      value(RV_AMOUNT_TYPE) type ZAMOUNT_TYPE .
  methods GET_AMOUNT_INVOICE
    importing
      !IS_ENTITYSET type CL_FAR_CUSTOMER_LINE_I_MPC=>TS_ITEM
    returning
      value(RV_AMOUNT_INVOICE) type ZAMOUNT_INVOICE .
  methods GET_AMOUNT_DEDUCTION
    importing
      !IS_ENTITYSET type CL_FAR_CUSTOMER_LINE_I_MPC=>TS_ITEM
    returning
      value(RV_AMOUNT_DEDUCTION) type ZAMOUNT_DEDUCTION .
  methods GET_AMOUNT_CREDIT
    importing
      !IS_ENTITYSET type CL_FAR_CUSTOMER_LINE_I_MPC=>TS_ITEM
    returning
      value(RV_AMOUNT_CREDIT) type ZAMOUNT_CREDIT .
ENDCLASS.



CLASS ZCL_ZFAR_CUSTOMER_LINE_DPC_EXT IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ZFAR_CUSTOMER_LINE_DPC_EXT->ADD_SELECT_PROPERTIES
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_TECH_FIELD_NAME             TYPE        STRING_TABLE
* | [--->] IT_FIELD_NAME                  TYPE        STRING_TABLE
* | [<-->] CS_REQUEST_DETAILS             TYPE        /IWBEP/IF_MGW_CORE_SRV_RUNTIME=>TY_S_MGW_REQUEST_CONTEXT
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD add_select_properties.

  APPEND LINES OF it_field_name TO cs_request_details-select_params.
  SORT cs_request_details-select_params.
  DELETE ADJACENT DUPLICATES FROM cs_request_details-select_params.
*
  APPEND LINES OF it_field_name TO cs_request_details-technical_request-select.
  SORT cs_request_details-technical_request-select.
  DELETE ADJACENT DUPLICATES FROM cs_request_details-technical_request-select.
*
  APPEND LINES OF it_field_name TO cs_request_details-technical_request-select_strings.
  SORT cs_request_details-technical_request-select_strings.
  DELETE ADJACENT DUPLICATES FROM cs_request_details-technical_request-select_strings.
*
  APPEND LINES OF it_field_name TO cs_request_details-technical_request-select_strings_h.
  SORT cs_request_details-technical_request-select_strings_h.
  DELETE ADJACENT DUPLICATES FROM cs_request_details-technical_request-select_strings_h.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ZFAR_CUSTOMER_LINE_DPC_EXT->GET_AMOUNT_CREDIT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_ENTITYSET                   TYPE        CL_FAR_CUSTOMER_LINE_I_MPC=>TS_ITEM
* | [<-()] RV_AMOUNT_CREDIT               TYPE        ZAMOUNT_CREDIT
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD get_amount_credit.

  rv_amount_credit =
    COND #( WHEN get_amount_type( is_entityset ) = 'C'
            THEN is_entityset-vh_amountincompanycodecurrency
            ELSE 0 ).

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ZFAR_CUSTOMER_LINE_DPC_EXT->GET_AMOUNT_DEDUCTION
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_ENTITYSET                   TYPE        CL_FAR_CUSTOMER_LINE_I_MPC=>TS_ITEM
* | [<-()] RV_AMOUNT_DEDUCTION            TYPE        ZAMOUNT_DEDUCTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD get_amount_deduction.

  rv_amount_deduction =
    COND #( WHEN get_amount_type( is_entityset ) = 'D'
            THEN is_entityset-vh_amountincompanycodecurrency
            ELSE 0 ).

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ZFAR_CUSTOMER_LINE_DPC_EXT->GET_AMOUNT_INVOICE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_ENTITYSET                   TYPE        CL_FAR_CUSTOMER_LINE_I_MPC=>TS_ITEM
* | [<-()] RV_AMOUNT_INVOICE              TYPE        ZAMOUNT_INVOICE
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD get_amount_invoice.

  rv_amount_invoice =
    COND #( WHEN get_amount_type( is_entityset ) = 'I'
            THEN is_entityset-vh_amountincompanycodecurrency
            ELSE 0 ).

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ZFAR_CUSTOMER_LINE_DPC_EXT->GET_AMOUNT_TYPE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_ENTITYSET                   TYPE        CL_FAR_CUSTOMER_LINE_I_MPC=>TS_ITEM
* | [<-()] RV_AMOUNT_TYPE                 TYPE        ZAMOUNT_TYPE
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD get_amount_type.

  rv_amount_type =
    COND #( WHEN is_entityset-vh_amountincompanycodecurrency < 0
            THEN 'C'
            ELSE COND #( WHEN is_entityset-vh_accountingdocumenttype = 'DR'
                           OR is_entityset-vh_accountingdocumenttype = 'RV'
                           OR is_entityset-vh_accountingdocumenttype = 'ZB'
                         THEN 'I'
                         ELSE 'D' ) ).

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ZFAR_CUSTOMER_LINE_DPC_EXT->IS_TOTAL
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_REQUEST_DETAILS             TYPE        /IWBEP/IF_MGW_CORE_SRV_RUNTIME=>TY_S_MGW_REQUEST_CONTEXT
* | [--->] IO_MODEL                       TYPE REF TO /IWBEP/IF_MGW_ODATA_FW_MODEL
* | [<-()] RV_IS_TOTAL                    TYPE        ABAP_BOOL
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD is_total.

  DATA(model) = CAST /iwbep/cl_mgw_odata_model( io_model ).
  TRY.
    rv_is_total = abap_true.
    DATA(wt_properties) = model->mt_entities[ name = 'Item' ]-properties.
    LOOP AT is_request_details-select_params ASSIGNING FIELD-SYMBOL(<s_select_params>).
      LOOP AT wt_properties ASSIGNING FIELD-SYMBOL(<s_properties>)
                            WHERE external_name = <s_select_params>.
        IF <s_properties>-semantic = '' AND
           <s_properties>-unit_property = ''.
          rv_is_total = abap_false.
        ENDIF.
    ENDLOOP.
  ENDLOOP.
  CATCH cx_sy_itab_line_not_found.
  ENDTRY.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZCL_ZFAR_CUSTOMER_LINE_DPC_EXT->ITEMSET_GET_ENTITYSET
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        STRING
* | [--->] IV_ENTITY_SET_NAME             TYPE        STRING
* | [--->] IV_SOURCE_NAME                 TYPE        STRING
* | [--->] IT_FILTER_SELECT_OPTIONS       TYPE        /IWBEP/T_MGW_SELECT_OPTION
* | [--->] IS_PAGING                      TYPE        /IWBEP/S_MGW_PAGING
* | [--->] IT_KEY_TAB                     TYPE        /IWBEP/T_MGW_NAME_VALUE_PAIR
* | [--->] IT_NAVIGATION_PATH             TYPE        /IWBEP/T_MGW_NAVIGATION_PATH
* | [--->] IT_ORDER                       TYPE        /IWBEP/T_MGW_SORTING_ORDER
* | [--->] IV_FILTER_STRING               TYPE        STRING
* | [--->] IV_SEARCH_STRING               TYPE        STRING
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITYSET(optional)
* | [<---] ET_ENTITYSET                   TYPE        CL_FAR_CUSTOMER_LINE_I_MPC=>TT_ITEM
* | [<---] ES_RESPONSE_CONTEXT            TYPE        /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_CONTEXT
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD itemset_get_entityset.
DATA: w_total_amount_invoice   TYPE zamount_invoice,
      w_total_amount_deduction TYPE zamount_deduction,
      w_total_amount_credit    TYPE zamount_credit.

* Get Information about Request Context (IO_TECH_REQUEST_CONTEXT)
  DATA(request_context) = cast /iwbep/cl_mgw_request( io_tech_request_context ).
  DATA(model) = request_context->get_model( ).
  DATA(wt_headers) = request_context->/iwbep/if_mgw_req_func_import~get_request_headers( ).
  DATA(ws_request_details) = request_context->get_request_details( ).
* Check if totals are read
  DATA(w_total) = is_total( is_request_details = ws_request_details
                            io_model           = model ).
* Check if custom fields totals are requested
  IF ( line_exists( ws_request_details-select_params[ table_line = 'ZZ_AMOUNT_INVOICE' ] ) OR
       line_exists( ws_request_details-select_params[ table_line = 'ZZ_AMOUNT_DEDUCTION' ] ) OR
       line_exists( ws_request_details-select_params[ table_line = 'ZZ_AMOUNT_CREDIT' ] ) )  AND
       w_total = abap_true.
*   Add standard fields that are required to calculate custome fields totals
    add_select_properties(
      EXPORTING
        it_tech_field_name = VALUE #( ( CONV string( 'CompanyCode' ) )
                                      ( CONV string( 'AccountingDocument' ) )
                                      ( CONV string( 'FiscalYear' ) )
                                      ( CONV string( 'AccountingDocumentItem' ) )
                                      ( CONV string( 'AccountingDocumentType' ) )
                                      ( CONV string( 'AmountInCompanyCodeCurrency' ) ) )
        it_field_name      = VALUE #( ( CONV string( 'COMPANYCODE' ) )
                                      ( CONV string( 'ACCOUNTINGDOCUMENT' ) )
                                      ( CONV string( 'FISCALYEAR' ) )
                                      ( CONV string( 'ACCOUNTINGDOCUMENTITEM' ) )
                                      ( CONV string( 'VH_ACCOUNTINGDOCUMENTTYPE' ) )
                                      ( CONV string( 'VH_AMOUNTINCOMPANYCODECURRENCY' ) ) )
      CHANGING
        cs_request_details = ws_request_details ).
*   Change paging to read all line information at document item level ( 100,000 should be enough)
    DATA(ws_paging) = VALUE /iwbep/s_mgw_paging( skip = 0
                                                 top = 100000 ).
    ws_request_details-paging = VALUE #( skip = 0
                                         top  = 100000 ).
*   Create modified Request Context (IO_TECH_REQUEST_CONTEXT)
    DATA(tech_request_context) =
      NEW /iwbep/cl_mgw_request(
        ir_request_details = ref #( ws_request_details )
        it_headers = wt_headers
        io_model = model ).
*   Get entity set
    super->itemset_get_entityset(
      EXPORTING
        iv_entity_name = iv_entity_name
        iv_entity_set_name = iv_entity_set_name
        iv_source_name = iv_source_name
        it_filter_select_options = it_filter_select_options
        is_paging = ws_paging
        it_key_tab = it_key_tab
        it_navigation_path = it_navigation_path
        it_order = it_order
        iv_filter_string = iv_filter_string
        iv_search_string         = iv_search_string
        io_tech_request_context = tech_request_context
      IMPORTING
        et_entityset = et_entityset
        es_response_context = es_response_context ).
*   Loop though entity set to calculate custom fields totals
    LOOP AT et_entityset ASSIGNING FIELD-SYMBOL(<s_entityset>).
      w_total_amount_invoice   = w_total_amount_invoice   + get_amount_invoice( <s_entityset> ).
      w_total_amount_deduction = w_total_amount_deduction + get_amount_deduction( <s_entityset> ).
      w_total_amount_credit    = w_total_amount_credit    + get_amount_credit( <s_entityset> ).
    ENDLOOP.
  ENDIF.

* Getting information about Request Context (IO_TECH_REQUEST_CONTEXT) again
  request_context = cast /iwbep/cl_mgw_request( io_tech_request_context ).
  ws_request_details = request_context->get_request_details( ).
* Check if custom fields are requested
  IF ( line_exists( ws_request_details-select_params[ table_line = 'ZZ_AMOUNT_INVOICE' ] ) OR
       line_exists( ws_request_details-select_params[ table_line = 'ZZ_AMOUNT_DEDUCTION' ] ) OR
       line_exists( ws_request_details-select_params[ table_line = 'ZZ_AMOUNT_CREDIT' ] ) OR
       line_exists( ws_request_details-select_params[ table_line = 'ZZ_AMOUNT_TYPE' ] ) )  AND
       w_total = abap_false.
*   Add standard fields that are required for custome fields calculation
    add_select_properties(
      EXPORTING
        it_tech_field_name = VALUE #( ( CONV string( 'CompanyCode' ) )
                                      ( CONV string( 'AccountingDocument' ) )
                                      ( CONV string( 'FiscalYear' ) )
                                      ( CONV string( 'AccountingDocumentItem' ) )
                                      ( CONV string( 'AccountingDocumentType' ) )
                                      ( CONV string( 'AmountInCompanyCodeCurrency' ) ) )
        it_field_name      = VALUE #( ( CONV string( 'COMPANYCODE' ) )
                                      ( CONV string( 'ACCOUNTINGDOCUMENT' ) )
                                      ( CONV string( 'FISCALYEAR' ) )
                                      ( CONV string( 'ACCOUNTINGDOCUMENTITEM' ) )
                                      ( CONV string( 'VH_ACCOUNTINGDOCUMENTTYPE' ) )
                                      ( CONV string( 'VH_AMOUNTINCOMPANYCODECURRENCY' ) ) )
      CHANGING
        cs_request_details = ws_request_details ).
  ENDIF.
* Create modified Request Context (IO_TECH_REQUEST_CONTEXT)
  tech_request_context =
    NEW /iwbep/cl_mgw_request(
      ir_request_details = ref #( ws_request_details )
      it_headers = wt_headers
      io_model = model ).
* Get entity set
  super->itemset_get_entityset(
    EXPORTING
      iv_entity_name = iv_entity_name
      iv_entity_set_name = iv_entity_set_name
      iv_source_name = iv_source_name
      it_filter_select_options = it_filter_select_options
      is_paging = is_paging
      it_key_tab = it_key_tab
      it_navigation_path = it_navigation_path
      it_order = it_order
      iv_filter_string = iv_filter_string
      iv_search_string         = iv_search_string
      io_tech_request_context = tech_request_context
    IMPORTING
      et_entityset = et_entityset
      es_response_context = es_response_context ).
* Calculate custom fields
  LOOP AT et_entityset ASSIGNING FIELD-SYMBOL(<ls_entity>).
    <ls_entity>-zz_amount_type = get_amount_type( <ls_entity> ).
    <ls_entity>-zz_amount_invoice =
      COND #( WHEN w_total = abap_true
              THEN w_total_amount_invoice
              ELSE get_amount_invoice( <ls_entity> ) ).
    <ls_entity>-zz_amount_deduction =
      COND #( WHEN w_total = abap_true
              THEN w_total_amount_deduction
              ELSE get_amount_deduction( <ls_entity> ) ).
    <ls_entity>-zz_amount_credit =
      COND #( WHEN w_total = abap_true
              THEN w_total_amount_credit
              ELSE get_amount_credit( <ls_entity> ) ).
  ENDLOOP.

ENDMETHOD.
ENDCLASS.