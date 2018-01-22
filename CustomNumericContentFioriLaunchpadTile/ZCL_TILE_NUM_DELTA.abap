class ZCL_TILE_NUM_DELTA definition
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
      value(RS_ENTITY) type ZCL_ZTILE_NUM_DELTA_MPC=>TS_ZTILE_NUM_DELTA .
protected section.
private section.

  class-methods GET_ENTITY_FLIGHT_PAYMENT
    returning
      value(RS_ENTITY) type ZCL_ZTILE_NUM_DELTA_MPC=>TS_ZTILE_NUM_DELTA .
	...	
ENDCLASS.



CLASS ZCL_TILE_NUM_DELTA IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_TILE_NUM_DELTA=>GET_ENTITY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITY
* | [<-()] RS_ENTITY                      TYPE        ZCL_ZTILE_NUM_DELTA_MPC=>TS_ZTILE_NUM_DELTA
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
* | Static Private Method ZCL_TILE_NUM_DELTA=>GET_ENTITY_FLIGHT_PAYMENT
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RS_ENTITY                      TYPE        ZCL_ZTILE_NUM_DELTA_MPC=>TS_ZTILE_NUM_DELTA
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD get_entity_flight_payment.

  rs_entity =
    VALUE #( icon              = 'sap-icon://money-bills'
             number            = '152'
             numberDigits      = '4'
             numberState       = 'Positive'              "Positive or Error
             numberFactor      = 'M'
             stateArrow        = 'Up'                    "None, Up or Down
             subtitle          = 'Dec 2017'
             title             = 'Fast Jet Payments'
             unit1             = '$'
             unit2             = '$'
             value1            = '152'
             value2            = '147'
             title1            = 'Jan 2018'
             title2            = 'Jan 2017'
             displayValue1     = '142 M'
             displayValue2     = '147 M'
             deltaDisplayValue = '+5'
             color             = 'Good' ).                "Good or Error

ENDMETHOD.
	...
ENDCLASS.