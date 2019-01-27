class ZCL_TILE_NUM_AREA definition
  public
  final
  create public .

public section.

  constants C_NEGATIVE type TEXT40 value 'Negative' ##NO_TEXT.
  constants C_NEUTRAL type TEXT40 value 'Neutral' ##NO_TEXT.
  constants C_POSITIVE type TEXT40 value 'Positive' ##NO_TEXT.
  constants C_ERROR type TEXT40 value 'Error' ##NO_TEXT.
  constants C_GOOD type TEXT40 value 'Good' ##NO_TEXT.
  constants C_DOWN type TEXT40 value 'Down' ##NO_TEXT.
  constants C_NONE type TEXT40 value 'None' ##NO_TEXT.
  constants C_UP type TEXT40 value 'Up' ##NO_TEXT.
  constants C_M type TEXT40 value 'M' ##NO_TEXT.
  constants C_B type TEXT40 value 'B' ##NO_TEXT.
  constants C_K type TEXT40 value 'K' ##NO_TEXT.

  class-methods GET_ENTITY
    importing
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY
    returning
      value(RS_ENTITY) type ZCL_ZTILE_NUM_AREA_MPC=>TS_ZTILE_NUM_AREA .
protected section.
private section.

  class-methods GET_ENTITY_FLIGHT_OCC
    returning
      value(RS_ENTITY) type ZCL_ZTILE_NUM_AREA_MPC=>TS_ZTILE_NUM_AREA .
  class-methods GET_NUMBER_STATE_MINIMIZE
    importing
      !IV_VALUE_1 type ANY
      !IV_VALUE_2 type ANY
    returning
      value(RV_NUMBER_STATE) type STRING .
  class-methods GET_NUMBER_STATE_MAXIMIZE
    importing
      !IV_VALUE_1 type ANY
      !IV_VALUE_2 type ANY
    returning
      value(RV_NUMBER_STATE) type STRING .
ENDCLASS.



CLASS ZCL_TILE_NUM_AREA IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_TILE_NUM_AREA=>GET_ENTITY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITY
* | [<-()] RS_ENTITY                      TYPE        ZCL_ZTILE_NUM_AREA_MPC=>TS_ZTILE_NUM_AREA
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD get_entity.

  DATA(wt_keys) = io_tech_request_context->get_keys( ).
  TRY.
    DATA(w_title) = wt_keys[ name = 'TITLE' ]-value.
    DATA(w_method) =
      REPLACE( val =  |GET_ENTITY_{ w_title CASE = UPPER }| regex = '\s'
        WITH = '_' OCC = 0 ).
    CALL METHOD (w_method) RECEIVING rs_entity = rs_entity.
  CATCH cx_sy_itab_line_not_found cx_sy_dyn_call_error.
  ENDTRY.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZCL_TILE_NUM_AREA=>GET_ENTITY_FLIGHT_OCC
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RS_ENTITY                      TYPE        ZCL_ZTILE_NUM_AREA_MPC=>TS_ZTILE_NUM_AREA
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD get_entity_flight_occ.
DATA: w_pointyvalue  TYPE i,
      w_targetyvalue TYPE i.

"  rs_entity = VALUE #(
"    icon             = 'sap-icon://waiver'
"    number           = '15.3'
"    numberDigits     = '5'
"    numberFactor     = ''
"    numberState      = get_number_state_maximize( iv_value_1 = '15.3' iv_value_2 = '11.0' )
"    numberUnit       = '%'
"    subtitle         = 'Top 10 Customers, Apr 2016 - Dec 2016'
"    title            = 'Customer P&L Marginal Profit'
"    unit1            = '%'
"    unit2            = '%'
"    firstXLabel      = 'Apr 2016'
"    lastXLabel       = 'Dec 2016'
"    minXValue        = '0'
"    maxXValue        = '100'
"    minYValue        = '0'
"    maxYValue        = '90'
"    point1YValue     = '25'
"    point2YValue     = '20'
"    point3YValue     = '20'
"    point4YValue     = '45'
"    target1YValue    = '10'
"    target2YValue    = '40'
"    target3YValue    = '40'
"    target4YValue    = '90'
" ).
  rs_entity = VALUE #(
    icon             = 'sap-icon://waiver'
    number           = '78.8'
    numberDigits     = '5'
    numberFactor     = ''
    numberState      = get_number_state_maximize( iv_value_1 = '78.8' iv_value_2 = '77.6' )
    numberUnit       = '%'
    subtitle         = 'Feb 2018 - Jan 2019'
    title            = 'Fastest Jet Seats Occupancy'
    unit1            = '%'
    unit2            = '%'
    firstXLabel      = 'Feb 2018'
    lastXLabel       = 'Jan 2019'
    minXValue        = '1'
    maxXValue        = '12'
    minYValue        = '76'
    maxYValue        = '81'
    point1YValue     = '78'
    point2YValue     = '76'
    point3YValue     = '79'
    point4YValue     = '78'
    point5YValue     = '80'
    point6YValue     = '77'
    point7YValue     = '79'
    point8YValue     = '79'
    point9YValue     = '80'
    point10YValue    = '79'
    point11YValue    = '80'
    point12YValue    = '81'
    target1YValue    = '80'
    target2YValue    = '79'
    target3YValue    = '78'
    target4YValue    = '76'
    target5YValue    = '78'
    target6YValue    = '76'
    target7YValue    = '77'
    target8YValue    = '80'
    target9YValue    = '77'
    target10YValue   = '76'
    target11YValue   = '78'
    target12YValue   = '77'
 ).
*
   DATA(wt_components) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( rs_entity ) )->components.
   LOOP AT wt_components ASSIGNING FIELD-SYMBOL(<s_components>) WHERE name CP 'POINT*XVALUE'.
     FIND ALL OCCURRENCES OF REGEX '([0-9]{1,2})' IN <s_components>-name SUBMATCHES DATA(s1).
     ASSIGN COMPONENT <s_components>-name OF STRUCTURE rs_entity TO FIELD-SYMBOL(<field>).
     <field> = s1.
   ENDLOOP.
   wt_components = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( rs_entity ) )->components.
   LOOP AT wt_components ASSIGNING <s_components> WHERE name CP 'TARGET*XVALUE'.
     FIND ALL OCCURRENCES OF REGEX '([0-9]{1,2})' IN <s_components>-name SUBMATCHES s1.
     ASSIGN COMPONENT <s_components>-name OF STRUCTURE rs_entity TO <field>.
     <field> = s1.
   ENDLOOP.
   LOOP AT wt_components ASSIGNING <s_components> WHERE name CP 'POINT*YVALUE'.
     ASSIGN COMPONENT <s_components>-name OF STRUCTURE rs_entity TO <field>.
     <field> = w_pointyvalue = COND #( WHEN <field> <> 0 THEN <field> ELSE w_pointyvalue ).
   ENDLOOP.
   LOOP AT wt_components ASSIGNING <s_components> WHERE name CP 'TARGET*YVALUE'.
     ASSIGN COMPONENT <s_components>-name OF STRUCTURE rs_entity TO <field>.
     <field> = w_targetyvalue = COND #( WHEN <field> <> 0 THEN <field> ELSE w_targetyvalue ).
   ENDLOOP.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZCL_TILE_NUM_AREA=>GET_NUMBER_STATE_MAXIMIZE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_VALUE_1                     TYPE        ANY
* | [--->] IV_VALUE_2                     TYPE        ANY
* | [<-()] RV_NUMBER_STATE                TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD get_number_state_maximize.

  rv_number_state = c_error.
  IF iv_value_1 >= iv_value_2.
    rv_number_state = c_positive.
  ENDIF.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZCL_TILE_NUM_AREA=>GET_NUMBER_STATE_MINIMIZE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_VALUE_1                     TYPE        ANY
* | [--->] IV_VALUE_2                     TYPE        ANY
* | [<-()] RV_NUMBER_STATE                TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD get_number_state_minimize.

  rv_number_state = c_positive.
  IF iv_value_1 > iv_value_2.
    rv_number_state = c_error.
  ENDIF.

ENDMETHOD.
ENDCLASS.