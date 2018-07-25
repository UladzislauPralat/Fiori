class ZCL_TILE_NUM_LINE definition
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
      value(RS_ENTITY) type ZCL_ZTILE_NUM_LINE_MPC=>TS_ZTILE_NUM_LINE .
protected section.
private section.

  class-methods GET_ENTITY_FLIGHT_OCC
    returning
      value(RS_ENTITY) type ZCL_ZTILE_NUM_LINE_MPC=>TS_ZTILE_NUM_LINE .
	...
ENDCLASS.



CLASS ZCL_TILE_NUM_LINE IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_TILE_NUM_LINE=>GET_ENTITY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITY
* | [<-()] RS_ENTITY                      TYPE        ZCL_ZTILE_NUM_LINE_MPC=>TS_ZTILE_NUM_LINE
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
* | Static Private Method ZCL_TILE_NUM_LINE=>GET_ENTITY_FLIGHT_OCC
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RS_ENTITY                      TYPE        ZCL_ZTILE_NUM_LINE_MPC=>TS_ZTILE_NUM_LINE
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD get_entity_flight_occ.
FIELD-SYMBOLS: <field> TYPE any.

  rs_entity = VALUE #(
    icon             = 'sap-icon://waiver'
    number           = '76.0'
    numberDigits     = '5'
    numberFactor     = ''
    numberState      = c_error
    numberUnit       = '%'
    subtitle         = 'Aug 2017 - Jul 2018'
    title            = 'Fastest Jet Flight Occupancy'
    unit1            = '%'
    unit2            = '%'
    leftBottomLabel  = 'Aug 2017'
    rightBottomLabel = 'Jul 2018'
    showPoints       = ''
    colorAbove       = 'Good'
    colorBelow       = 'Error'
    threshold        = '80'
    minXValue        = 1
    maxXValue        = 12
    minYValue        = '65'
    maxYValue        = '81'
    point1YValue     = '81'
    point2YValue     = '80'
    point3YValue     = '79'
    point4YValue     = '75'
    point5YValue     = '65'
    point6YValue     = '70'
    point7YValue     = '81'
    point8YValue     = '80'
    point9YValue     = '79'
    point10YValue    = '75'
    point11YValue    = '65'
    point12YValue    = '70'     ).
*  Set default values for remaining data points
   DATA(wt_components) =  CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( rs_entity ) )->components.
   LOOP AT wt_components ASSIGNING FIELD-SYMBOL(<s_components>) WHERE name CP 'POINT*XVALUE'.
     FIND ALL OCCURRENCES OF REGEX '([0-9]{1,2})' IN <s_components>-name SUBMATCHES DATA(s1).
     ASSIGN COMPONENT <s_components>-name OF STRUCTURE rs_entity TO <field>.
     <field> = s1.
   ENDLOOP.

ENDMETHOD.
	...	

ENDCLASS.