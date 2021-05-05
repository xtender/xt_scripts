accept _path_to_pdb_archive prompt "Enter the path to .pdb archive: ";
accept _pdb_name            prompt "Enter the PDB name: ";
SET SERVEROUTPUT ON
DECLARE
  l_result BOOLEAN;
BEGIN
  l_result := DBMS_PDB.check_plug_compatibility(
                pdb_descr_file => '&_path_to_pdb_archive',
                pdb_name       => '&_pdb_name');

  IF l_result THEN
    DBMS_OUTPUT.PUT_LINE('compatible');
  ELSE
    DBMS_OUTPUT.PUT_LINE('incompatible');
  END IF;
END;
/