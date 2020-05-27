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
      !IT_FIELD_NAME type STRING_TABLE
    changing
      !CS_REQUEST_DETAILS type /IWBEP/IF_MGW_CORE_SRV_RUNTIME=>TY_S_MGW_REQUEST_CONTEXT .
  methods DELETE_FILTER_PROPERTIES
    importing
      !IT_FIELD_NAME type STRING_TABLE
    changing
      !CS_REQUEST_DETAILS type /IWBEP/IF_MGW_CORE_SRV_RUNTIME=>TY_S_MGW_REQUEST_CONTEXT .
  methods GET_AMOUNT_TYPE
    importing
      !IS_ENTITYSET type CL_FAR_CUSTOMER_LINE_I_MPC=>TS_ITEM
    returning
      value(RV_AMOUNT_TYPE) type ZAMOUNT_TYPE .
  methods GET_AGING_GROUP
    importing
      !IS_ENTITYSET type CL_FAR_CUSTOMER_LINE_I_MPC=>TS_ITEM
    returning
      value(RV_AGING_GROUP) type ZAGING_GROUP .
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
  methods GET_TOTAL
    importing
      !IS_REQUEST_DETAILS type /IWBEP/IF_MGW_CORE_SRV_RUNTIME=>TY_S_MGW_REQUEST_CONTEXT
      !IT_ENTITYSET type CL_FAR_CUSTOMER_LINE_I_MPC=>TT_ITEM
      !IO_MODEL type ref to /IWBEP/IF_MGW_ODATA_FW_MODEL
    exporting
      value(ET_ENTITYSET) type CL_FAR_CUSTOMER_LINE_I_MPC=>TT_ITEM .
  methods MAP_TOTAL
    importing
      !IS_REQUEST_DETAILS type /IWBEP/IF_MGW_CORE_SRV_RUNTIME=>TY_S_MGW_REQUEST_CONTEXT
      !IT_ENTITYSET type CL_FAR_CUSTOMER_LINE_I_MPC=>TT_ITEM
      !IT_FILTER_SELECT_OPTIONS type /IWBEP/T_MGW_SELECT_OPTION
      !IO_MODEL type ref to /IWBEP/IF_MGW_ODATA_FW_MODEL
    changing
      value(CS_ENTITYSET) type CL_FAR_CUSTOMER_LINE_I_MPC=>TS_ITEM .
ENDCLASS.



CLASS ZCL_ZFAR_CUSTOMER_LINE_DPC_EXT IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ZFAR_CUSTOMER_LINE_DPC_EXT->ADD_SELECT_PROPERTIES
* +-------------------------------------------------------------------------------------------------+
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
* | Instance Private Method ZCL_ZFAR_CUSTOMER_LINE_DPC_EXT->DELETE_FILTER_PROPERTIES
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_FIELD_NAME                  TYPE        STRING_TABLE
* | [<-->] CS_REQUEST_DETAILS             TYPE        /IWBEP/IF_MGW_CORE_SRV_RUNTIME=>TY_S_MGW_REQUEST_CONTEXT
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD delete_filter_properties.

  LOOP AT it_field_name ASSIGNING FIELD-SYMBOL(<s_field_name>).
    DELETE cs_request_details-filter_select_options WHERE property = <s_field_name>.
    LOOP AT cs_request_details-technical_request-filter_expressions INTO DATA(wa_filter_expressions)
                                                                    WHERE l_operand = <s_field_name>.
      DELETE cs_request_details-technical_request-filter_expressions WHERE rop_id = wa_filter_expressions-expression_id.
    ENDLOOP.
    DELETE cs_request_details-technical_request-filter_expressions WHERE l_operand = <s_field_name>.
    DELETE cs_request_details-technical_request-filter_select_options WHERE property = to_upper( <s_field_name> ).
    DELETE cs_request_details-technical_request-filter_select_placeholders WHERE property = to_upper( <s_field_name> ).
  ENDLOOP.

  DATA(wt_filter_expressions) = cs_request_details-technical_request-filter_expressions.
  DO LINES( wt_filter_expressions ) TIMES.
     IF wt_filter_expressions[ LINES( wt_filter_expressions ) + 1 - sy-index ]-rop_type = 'B'.
       IF LINE_EXISTS(
            wt_filter_expressions[ lop_type = 'B'
                                   expression_id = wt_filter_expressions[ LINES( wt_filter_expressions ) + 1 - sy-index ]-rop_id ] ).
          DELETE cs_request_details-technical_request-filter_expressions
            WHERE expression_id = wt_filter_expressions[ LINES( wt_filter_expressions ) + 1 - sy-index ]-expression_id.
       ENDIF.
    ENDIF.
  ENDDO.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ZFAR_CUSTOMER_LINE_DPC_EXT->GET_AGING_GROUP
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_ENTITYSET                   TYPE        CL_FAR_CUSTOMER_LINE_I_MPC=>TS_ITEM
* | [<-()] RV_AGING_GROUP                 TYPE        ZAGING_GROUP
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD get_aging_group.

  rv_aging_group =
    COND #( WHEN is_entityset-netduearrearsdays <= 0 THEN '..0'
            WHEN is_entityset-netduearrearsdays BETWEEN 1 AND 30 THEN '1..30'
            WHEN is_entityset-netduearrearsdays BETWEEN 31 AND 60 THEN '31..60'
            WHEN is_entityset-netduearrearsdays BETWEEN 61 AND 90 THEN '61..90'
            WHEN is_entityset-netduearrearsdays >= 91 THEN '91..' ).

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
* | Instance Private Method ZCL_ZFAR_CUSTOMER_LINE_DPC_EXT->GET_TOTAL
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_REQUEST_DETAILS             TYPE        /IWBEP/IF_MGW_CORE_SRV_RUNTIME=>TY_S_MGW_REQUEST_CONTEXT
* | [--->] IT_ENTITYSET                   TYPE        CL_FAR_CUSTOMER_LINE_I_MPC=>TT_ITEM
* | [--->] IO_MODEL                       TYPE REF TO /IWBEP/IF_MGW_ODATA_FW_MODEL
* | [<---] ET_ENTITYSET                   TYPE        CL_FAR_CUSTOMER_LINE_I_MPC=>TT_ITEM
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD get_total.
DATA: wa_entityset TYPE cl_far_customer_line_i_mpc=>ts_item.

  DATA(model) = CAST /iwbep/cl_mgw_odata_model( io_model ).
  DATA(wt_properties) = model->mt_entities[ name = 'Item' ]-properties.
  LOOP AT it_entityset ASSIGNING FIELD-SYMBOL(<s_entityset>).
    LOOP AT is_request_details-select_params ASSIGNING FIELD-SYMBOL(<s_select_params>).
      TRY.
        IF wt_properties[ name = to_upper( <s_select_params> ) ]-unit_property <> '' OR
           wt_properties[ name = to_upper( <s_select_params> ) ]-semantic <> ''.
          ASSIGN COMPONENT <s_select_params> OF STRUCTURE <s_entityset> TO FIELD-SYMBOL(<from>).
          ASSIGN COMPONENT <s_select_params> OF STRUCTURE wa_entityset  TO FIELD-SYMBOL(<to>).
            <to> = <from>.
          ENDIF.
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.
    ENDLOOP.
    COLLECT wa_entityset INTO et_entityset.
    CLEAR: wa_entityset.
  ENDLOOP.

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
*DATA: ws_entityset TYPE cl_far_customer_line_i_mpc=>ts_item.
FIELD-SYMBOLS: <s_entityset> TYPE cl_far_customer_line_i_mpc=>ts_item.
CONSTANTS: c_top TYPE i VALUE 1000000.

* Get Information about Request Context (IO_TECH_REQUEST_CONTEXT)
  DATA(request_context) = CAST /iwbep/cl_mgw_request( io_tech_request_context ).
  DATA(model) = request_context->get_model( ).
  DATA(wt_headers) = request_context->get_request_headers( ).
  DATA(ws_request_details) = request_context->get_request_details( ).
* Delete custom filter proprties that not supported by standard data provider
  delete_filter_properties(
    EXPORTING
      it_field_name      = VALUE #( ( CONV string( 'AmountType' ) )
                                    ( CONV string( 'AgingGroup' ) ) )
    CHANGING
      cs_request_details = ws_request_details  ).
  DATA(wt_filter_select_options) = it_filter_select_options.
  DELETE wt_filter_select_options WHERE property = 'AmountType'
                                     OR property = 'AgingGroup'.
* Check if totals are read
  DATA(w_total) = is_total( is_request_details = ws_request_details
                            io_model           = model ).
* Check if custom properties totals or filters required
  IF ( w_total = abap_true ) AND
     ( line_exists( ws_request_details-select_params[ table_line = 'AmountInvoice' ] ) OR
       line_exists( ws_request_details-select_params[ table_line = 'AmountDeduction' ] ) OR
       line_exists( ws_request_details-select_params[ table_line = 'AmountCredit' ] ) OR
       line_exists( it_filter_select_options[ property = 'AmountType' ] ) OR
       line_exists( it_filter_select_options[ property = 'AgingGroup' ] ) ).
*   Add standard fields that are required to calculate custom fields totals
    add_select_properties(
      EXPORTING
        it_field_name      = VALUE #( ( CONV string( 'COMPANYCODE' ) )
                                      ( CONV string( 'ACCOUNTINGDOCUMENT' ) )
                                      ( CONV string( 'FISCALYEAR' ) )
                                      ( CONV string( 'ACCOUNTINGDOCUMENTITEM' ) )
                                      ( CONV string( 'VH_COMPANYCODECURRENCY' ) )
                                      ( CONV string( 'VH_ACCOUNTINGDOCUMENTTYPE' ) )
                                      ( CONV string( 'VH_AMOUNTINCOMPANYCODECURRENCY' ) )
                                      ( CONV string( 'NETDUEARREARSDAYS' ) ) )
      CHANGING
        cs_request_details = ws_request_details ).
*   Change paging to read all line information at document item level
    DATA(ws_paging) = VALUE /iwbep/s_mgw_paging( skip = 0
                                                 top = c_top ).
    ws_request_details-paging = VALUE #( skip = 0
                                         top  = c_top ).
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
        it_filter_select_options = wt_filter_select_options
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
    LOOP AT et_entityset ASSIGNING <s_entityset>.
*     Apply custom properties filter
      IF line_exists( it_filter_select_options[ property = 'AmountType' ] ).
        IF get_amount_type( <s_entityset> ) NOT IN it_filter_select_options[ property = 'AmountType' ]-select_options.
          DELETE et_entityset.
          CONTINUE.
        ENDIF.
      ENDIF.
      IF line_exists( it_filter_select_options[ property = 'AgingGroup' ] ).
        IF get_aging_group( <s_entityset> ) NOT IN it_filter_select_options[ property = 'AgingGroup' ]-select_options.
          DELETE et_entityset.
          CONTINUE.
        ENDIF.
      ENDIF.
*     Calculate custom properties
      <s_entityset>-amountinvoice = get_amount_invoice( <s_entityset> ).
      <s_entityset>-amountdeduction = get_amount_deduction( <s_entityset> ).
      <s_entityset>-amountcredit = get_amount_credit( <s_entityset> ).
    ENDLOOP.
*   Calculate totals
    get_total(
      EXPORTING
       is_request_details = ws_request_details
       it_entityset       = et_entityset
       io_model           = model
      IMPORTING
       et_entityset       = DATA(wt_entityset_total) ).
  ENDIF.

* Getting information about Request Context (IO_TECH_REQUEST_CONTEXT) again
  request_context = cast /iwbep/cl_mgw_request( io_tech_request_context ).
  ws_request_details = request_context->get_request_details( ).
* Delete custom properties filtering
  delete_filter_properties(
    EXPORTING
      it_field_name      = VALUE #( ( CONV string( 'AmountType' ) )
                                    ( CONV string( 'AgingGroup' ) ) )
    CHANGING
      cs_request_details = ws_request_details  ).

* Check if custom fields are requested
  IF ( line_exists( ws_request_details-select_params[ table_line = 'AmountInvoice' ] ) OR
       line_exists( ws_request_details-select_params[ table_line = 'AmountDeduction' ] ) OR
       line_exists( ws_request_details-select_params[ table_line = 'AmountCredit' ] ) OR
       line_exists( ws_request_details-select_params[ table_line = 'AmountType' ] ) OR
       line_exists( ws_request_details-select_params[ table_line = 'AgingGroup' ] ) OR
       line_exists( it_filter_select_options[ property = 'AmountType' ] ) OR
       line_exists( it_filter_select_options[ property = 'AgingGroup' ] ) )  AND
       w_total = abap_false.
*   Add standard fields that are required for custome fields calculation
    add_select_properties(
      EXPORTING
        it_field_name      = VALUE #( ( CONV string( 'COMPANYCODE' ) )
                                      ( CONV string( 'ACCOUNTINGDOCUMENT' ) )
                                      ( CONV string( 'FISCALYEAR' ) )
                                      ( CONV string( 'ACCOUNTINGDOCUMENTITEM' ) )
                                      ( CONV string( 'VH_ACCOUNTINGDOCUMENTTYPE' ) )
                                      ( CONV string( 'VH_AMOUNTINCOMPANYCODECURRENCY' ) )
                                      ( CONV string( 'NETDUEARREARSDAYS' ) ) )
      CHANGING
        cs_request_details = ws_request_details ).
  ENDIF.
  ws_paging = is_paging.
* Read all data before applying custom property filters
  IF w_total = abap_false AND ( line_exists( it_filter_select_options[ property = 'AmountType' ] ) OR
                                line_exists( it_filter_select_options[ property = 'AgingGroup' ] ) ).
    ws_paging = VALUE #( skip = 0
                         top = c_top ).
    ws_request_details-paging = VALUE #( skip = 0
                                         top  = c_top ).
  ENDIF.
* Create modified Request Context (IO_TECH_REQUEST_CONTEXT)
  tech_request_context =
    NEW /iwbep/cl_mgw_request(
      ir_request_details = REF #( ws_request_details )
      it_headers = wt_headers
      io_model = model ).
* Get entity set
  super->itemset_get_entityset(
    EXPORTING
      iv_entity_name = iv_entity_name
      iv_entity_set_name = iv_entity_set_name
      iv_source_name = iv_source_name
      it_filter_select_options = wt_filter_select_options
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
*
  LOOP AT et_entityset ASSIGNING <s_entityset>.
*   Apply customer properties filter
    IF w_total = abap_false AND line_exists( it_filter_select_options[ property = 'AmountType' ] ).
      IF get_amount_type( <s_entityset> ) NOT IN it_filter_select_options[ property = 'AmountType' ]-select_options.
        DELETE et_entityset.
        CONTINUE.
      ENDIF.
    ENDIF.
    IF w_total = abap_false AND line_exists( it_filter_select_options[ property = 'AgingGroup' ] ).
      IF get_aging_group( <s_entityset> ) NOT IN it_filter_select_options[ property = 'AgingGroup' ]-select_options.
        DELETE et_entityset.
        CONTINUE.
      ENDIF.
    ENDIF.
    IF line_exists( ws_request_details-select_params[ table_line = 'AmountType' ] ).
      <s_entityset>-amounttype = get_amount_type( <s_entityset> ).
    ENDIF.
    IF line_exists( ws_request_details-select_params[ table_line = 'AgingGroup' ] ).
      <s_entityset>-aginggroup = get_aging_group( <s_entityset> ).
    ENDIF.
    IF ( w_total = abap_false ) AND
       ( line_exists( ws_request_details-select_params[ table_line = 'AmountInvoice' ] ) OR
         line_exists( ws_request_details-select_params[ table_line = 'AmountDeduction' ] ) OR
         line_exists( ws_request_details-select_params[ table_line = 'AmountCredit' ] ) ).
       <s_entityset>-amountinvoice   = get_amount_invoice( <s_entityset> ).
       <s_entityset>-amountdeduction = get_amount_deduction( <s_entityset> ).
       <s_entityset>-amountcredit    = get_amount_credit( <s_entityset> ).
    ENDIF.
    IF ( w_total = abap_true ) AND
       ( line_exists( ws_request_details-select_params[ table_line = 'AmountInvoice' ] ) OR
         line_exists( ws_request_details-select_params[ table_line = 'AmountDeduction' ] ) OR
         line_exists( ws_request_details-select_params[ table_line = 'AmountCredit' ] ) OR
         line_exists( it_filter_select_options[ property = 'AmountType' ] ) OR
         line_exists( it_filter_select_options[ property = 'AgingGroup' ] ) ).
      map_total(
        EXPORTING
          is_request_details       = ws_request_details
          it_entityset             = wt_entityset_total
          it_filter_select_options = it_filter_select_options
          io_model                 = model
        CHANGING
          cs_entityset             = <s_entityset> ).
    ENDIF.
  ENDLOOP.
  IF w_total = abap_false AND ( line_exists( it_filter_select_options[ property = 'AmountType' ] ) OR
                                line_exists( it_filter_select_options[ property = 'AgingGroup' ] ) ).
*   Change inline count after applying custom properties filter
    es_response_context-inlinecount = LINES( et_entityset ).
*   Return only portion of data requested by client after applying custom properties filter
    DATA(wt_entityset) = et_entityset.
    CLEAR: et_entityset.
    APPEND LINES OF wt_entityset
      FROM ( is_paging-skip + 1 ) TO ( is_paging-skip + is_paging-top )
      TO et_entityset.
  ENDIF.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ZFAR_CUSTOMER_LINE_DPC_EXT->MAP_TOTAL
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_REQUEST_DETAILS             TYPE        /IWBEP/IF_MGW_CORE_SRV_RUNTIME=>TY_S_MGW_REQUEST_CONTEXT
* | [--->] IT_ENTITYSET                   TYPE        CL_FAR_CUSTOMER_LINE_I_MPC=>TT_ITEM
* | [--->] IT_FILTER_SELECT_OPTIONS       TYPE        /IWBEP/T_MGW_SELECT_OPTION
* | [--->] IO_MODEL                       TYPE REF TO /IWBEP/IF_MGW_ODATA_FW_MODEL
* | [<-->] CS_ENTITYSET                   TYPE        CL_FAR_CUSTOMER_LINE_I_MPC=>TS_ITEM
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD map_total.
DATA: wa_entityset TYPE cl_far_customer_line_i_mpc=>ts_item.

  DATA(model) = CAST /iwbep/cl_mgw_odata_model( io_model ).
  DATA(wt_properties) = model->mt_entities[ name = 'Item' ]-properties.
* Map unit properties into work area
  LOOP AT wt_properties ASSIGNING FIELD-SYMBOL(<s_properties>) WHERE semantic <> ''.
    ASSIGN COMPONENT <s_properties>-name OF STRUCTURE cs_entityset TO FIELD-SYMBOL(<from>).
    ASSIGN COMPONENT <s_properties>-name OF STRUCTURE wa_entityset  TO FIELD-SYMBOL(<to>).
    <to> = <from>.
  ENDLOOP.
* Lookup custom totals by unit properties
  READ TABLE it_entityset FROM wa_entityset INTO wa_entityset.
* Map amount / quantity fields from custom to standard totals
  LOOP AT is_request_details-select_params ASSIGNING FIELD-SYMBOL(<s_select_params>).
    TRY.
      IF wt_properties[ external_name = <s_select_params> ]-unit_property <> ''.
*       Map totals:
*         1) always for customer fields
*         2) for standard fields only if selection by custom fields takes place
        IF <s_select_params> = 'AmountInvoice' OR
           <s_select_params> = 'AmountDeduction' OR
           <s_select_params> = 'AmountCredit' OR
           line_exists( it_filter_select_options[ property = 'AmountType' ] ) OR
           line_exists( it_filter_select_options[ property = 'AgingGroup' ] ).
          ASSIGN COMPONENT wt_properties[ external_name = <s_select_params> ]-name OF STRUCTURE wa_entityset TO <from>.
          ASSIGN COMPONENT wt_properties[ external_name = <s_select_params> ]-name OF STRUCTURE cs_entityset  TO <to>.
          <to> = <from>.
         ENDIF.
      ENDIF.
    CATCH cx_sy_itab_line_not_found.
    ENDTRY.
  ENDLOOP.

ENDMETHOD.
ENDCLASS.