class ZCL_TILE_NUM_COL4 definition
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
      value(RS_ENTITY) type ZCL_ZTILE_NUM_COL4_MPC=>TS_ZTILE_NUM_COL4 .
protected section.
private section.

  class-methods GET_ENTITY_FLIGHT_OCC
    returning
      value(RS_ENTITY) type ZCL_ZTILE_NUM_COL4_MPC=>TS_ZTILE_NUM_COL4 .
	...
ENDCLASS.



CLASS ZCL_TILE_NUM_COL4 IMPLEMENTATION.

* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_TILE_NUM_COL4=>GET_ENTITY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITY
* | [<-()] RS_ENTITY                      TYPE        ZCL_ZTILE_NUM_COL4_MPC=>TS_ZTILE_NUM_COL4
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD get_entity.

  DATA(wt_keys) = io_tech_request_context->get_keys( ).
  TRY.
    DATA(w_title) = wt_keys[ name = 'TITLE' ]-value.
    DATA(w_method) = REPLACE( val =  |GET_ENTITY_{ w_title CASE = UPPER }| regex = '\s' WITH = '_' OCC = 0 ).
    CALL METHOD (w_method) RECEIVING rs_entity = rs_entity.
  CATCH cx_sy_itab_line_not_found cx_sy_dyn_call_error.
  ENDTRY.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZCL_TILE_NUM_COL4=>GET_ENTITY_FLIGHT_OCC
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RS_ENTITY                      TYPE        ZCL_ZTILE_NUM_COL4_MPC=>TS_ZTILE_NUM_COL4
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD get_entity_flight_occ.

  rs_entity = VALUE #(
    icon             = 'sap-icon://waiver'
    number           = '76.0'
    numberDigits     = '5'
    numberFactor     = ''
    numberState      = 'Error'                           "Positive or Error
    numberUnit       = '%'
    subtitle         = 'FTD 2017'
    title            = 'Fastest Jet Seats Occupancy'
    unit1            = '%'
    unit2            = '%'
    leftTopLabel     = '2017 Q2'
    rightTopLabel    = '2018 Q1'
    value1           = 80
    value2           = 70
    value3           = 75
    value4           = 81
    color1           = 'Good'
    color2           = 'Error'
    color3           = 'Error'
    color4           = 'Good' ).

ENDMETHOD.
	...
ENDCLASS.