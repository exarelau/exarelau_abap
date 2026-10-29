*&---------------------------------------------------------------------*
*& Report zrep_mara_alv
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zrep_mara_alv.

TABLES mara.

SELECT-OPTIONS s_matnr FOR mara-matnr.
PARAMETERS p_max TYPE i DEFAULT 500.

AT SELECTION-SCREEN.
	IF p_max <= 0.
		MESSAGE 'Maximum row count must be greater than zero.' TYPE 'E'.
	ENDIF.

START-OF-SELECTION.
	SELECT FROM mara
		FIELDS matnr, mtart, matkl, meins, ersda, laeda, lvorm
		WHERE matnr IN @s_matnr
		ORDER BY matnr
		INTO TABLE @DATA(lt_materials)
		UP TO @p_max ROWS.

	IF lt_materials IS INITIAL.
		MESSAGE 'No materials found.' TYPE 'S' DISPLAY LIKE 'I'.
		RETURN.
	ENDIF.
	if sy-uname EQ 'EXARELAU'.
		MESSAGE 'This report is not available for user EXarelaU.' TYPE 'S' DISPLAY LIKE 'E'.
	endif.
	TRY.
			cl_salv_table=>factory(
				IMPORTING
					r_salv_table = DATA(lo_alv)
				CHANGING
					t_table      = lt_materials ).
			lo_alv->get_functions( )->set_all( abap_true ).
			lo_alv->get_columns( )->set_optimize( abap_true ).
			lo_alv->display( ).
		CATCH cx_salv_msg INTO DATA(lx_salv).
			MESSAGE lx_salv->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
	ENDTRY.