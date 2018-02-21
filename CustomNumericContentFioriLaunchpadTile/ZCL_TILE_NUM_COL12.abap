class ZCL_TILE_NUM_COL12 definition
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
      value(RS_ENTITY) type ZCL_ZTILE_NUM_COL12_MPC=>TS_ZTILE_NUM_COL12 .
protected section.
private section.

  class-methods GET_ENTITY_FLIGHT_OCC
    returning
      value(RS_ENTITY) type ZCL_ZTILE_NUM_COL12_MPC=>TS_ZTILE_NUM_COL12 .
	...	
ENDCLASS.



CLASS ZCL_TILE_NUM_COL12 IMPLEMENTATION.

* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_TILE_NUM_COL12=>GET_ENTITY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITY
* | [<-()] RS_ENTITY                      TYPE        ZCL_ZTILE_NUM_COL12_MPC=>TS_ZTILE_NUM_COL12
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
* | Static Private Method ZCL_TILE_NUM_COL12=>GET_ENTITY_FLIGHT_OCC
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RS_ENTITY                      TYPE        ZCL_ZTILE_NUM_COL12_MPC=>TS_ZTILE_NUM_COL12
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
    leftTopLabel     = 'Apr 2017'
    rightTopLabel    = 'Mar 2018'
    value1           = 81
    value2           = 80
    value3           = 79
    value4           = 75
    value5           = 65
    value6           = 70
    value7           = 76
    value8           = 75
    value9           = 74
    value10          = 77
    value11          = 85
    value12          = 0
    color1           = 'Good'
    color2           = 'Good'
    color3           = 'Error'
    color4           = 'Error'
    color5           = 'Error'
    color6           = 'Error'
    color7           = 'Error'
    color8           = 'Error'
    color9           = 'Error'
    color10          = 'Error'
    color11          = 'Good'
    color12          = 'Neutral' ).

ENDMETHOD.
	...
ENDCLASS.