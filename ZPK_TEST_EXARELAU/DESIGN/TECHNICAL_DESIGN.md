# Technical Design: ZREP_MARA_ALV

## Document Status

Draft, as-is technical description based on the inspected ABAP source and package metadata on 2026-10-30. No technical target-state requirement was provided. Runtime behavior, authorizations, and API release status were not independently verified.

## Repository Object

| Attribute | Value |
| --- | --- |
| Package | `ZPK_TEST_EXARELAU` |
| Package description | `TEST ONLY. PLEASE DO NOT TRANSPORT.` |
| Software component | `HOME` |
| Transport layer | `ZDEV` |
| Program | `ZREP_MARA_ALV` |
| Program description | `Display material master data from MARA as ALV` |
| Program type | Executable report |

The package warning is metadata, not evidence of an enforced transport restriction.

## Runtime Flow

1. Define `S_MATNR` as a select-option for `MARA-MATNR` and `P_MAX` as integer parameter with default 500.
2. In `AT SELECTION-SCREEN`, raise a type `E` message if `P_MAX <= 0`.
3. In `START-OF-SELECTION`, execute an Open SQL read against `MARA` for `MATNR`, `MTART`, `MATKL`, `MEINS`, `ERSDA`, `LAEDA`, and `LVORM`.
4. Apply the `S_MATNR` range, order by `MATNR`, and limit the result to `P_MAX` rows. Store the result in local internal table `LT_MATERIALS`.
5. If the table is empty, display “No materials found” as a success message with informational display styling and return.
6. If `SY-UNAME` equals `EXARELAU`, display the user-specific success message with error display styling. There is no `RETURN` or other stop, so execution continues.
7. Create the SALV table, enable all SALV functions, optimize columns, and display it.
8. Catch `CX_SALV_MSG` and display its text as a success message with error styling.

## Components and Data Flow

- Database source: `MARA` (read only in this report).
- Input: `S_MATNR`, `P_MAX`, and system user `SY-UNAME`.
- Processing: one ordered, row-limited Open SQL query; no additional calculations or enrichment.
- Output: interactive SALV list using standard `CL_SALV_TABLE`.
- External interfaces and update operations: none observed.

## Error Handling and Security

- Invalid row count is handled during selection-screen processing with a type `E` message.
- No-result condition is handled with a status message and early return.
- SALV creation/display exception `CX_SALV_MSG` is caught.
- No explicit `AUTHORITY-CHECK` is present. Required report-start and material-data authorization behavior must be confirmed in the target system; it is not safe to infer it from this source.
- The `EXARELAU` branch is not an authorization control: data is read before the branch, and output is still displayed.

## Performance and Operational Considerations

- `P_MAX` limits rows but has no enforced upper bound.
- The material range is optional. A broad or empty range combined with a high `P_MAX` may read many rows.
- `ORDER BY MATNR` is explicit. Database performance and index behavior were not measured.
- The implementation is interactive and has no batch-specific output handling.

## Text and UI Resources

- Source contains hard-coded English messages for invalid row count, no results, and the `EXARELAU` condition.
- The English text resource file is empty.
- Selection text resources currently contain placeholder labels for `P_MAX` and `S_MATNR`.
- List and column heading resources are present but blank.
- ATC reported informational findings for all three hard-coded strings being untranslated.

## Technical Validation Evidence

- ABAP object check: successful.
- ATC: 3 informational findings, 0 errors, 0 warnings; findings are hard-coded, untranslated strings.
- No runtime execution, authorization test, performance test, or Clean Core/API release assessment was performed.

## Technical Test Scenarios

| ID | Test | Expected result / evidence |
| --- | --- | --- |
| TD-01 | Syntax/object check | Object check completes successfully. |
| TD-02 | `P_MAX` <= 0 | Selection-screen validation prevents report processing. |
| TD-03 | Matching and non-matching material ranges | Query honors range, row limit, and ascending `MATNR` order. |
| TD-04 | Empty material range with a high `P_MAX` | Confirm volume, runtime, and whether an empty range is acceptable. |
| TD-05 | Execute as `EXARELAU` with matches | Confirm message is displayed and ALV still appears in current implementation. |
| TD-06 | Execute without required SAP authorization | Verify effective authorization behavior in the target system; not verified by source inspection. |
| TD-07 | Trigger or simulate SALV exception where feasible | Confirm catch path displays the exception text and does not dump. |
| TD-08 | ATC | Current baseline reports three informational untranslated-string findings. |

## Technical Open Points

1. Confirm supported SAP release and whether the used Open SQL and SALV APIs meet the target system standards.
2. Confirm whether an empty material range and a high row limit are acceptable; define a maximum if required.
3. Confirm required report and table authorizations using approved roles and read-only system evidence.
4. Decide whether user-specific restriction logic is required and, if so, define the approved enforcement design.
5. Decide whether to populate text elements and selection/list labels.
6. Confirm package transport policy; package metadata warns not to transport, but enforcement was not checked.