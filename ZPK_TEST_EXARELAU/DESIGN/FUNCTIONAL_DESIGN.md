# Functional Design: ZREP_MARA_ALV

## Document Status

Draft, as-is characterization based on the ABAP source and package metadata inspected on 2026-10-30. No approved business requirement or target-state decision was supplied. This document distinguishes observed behavior from assumptions and open questions; it does not authorize a process change.

## Business Purpose

The report reads material master records from `MARA` and presents selected attributes in an ALV list. This purpose is inferred from the implementation, not traced to an approved requirement.

## Scope

In scope:

- Selection by material number using `S_MATNR`.
- Selection of a maximum row count using `P_MAX`.
- Read and display of material number, material type, material group, base unit, creation date, last-change date, and deletion flag.
- Read-only ALV presentation.

Out of scope in the inspected implementation:

- Creating, changing, or deleting material master records.
- Updating any SAP data.
- Interfaces, background scheduling, or persisted output.
- A confirmed business authorization model.

## Actors and Current Process

The report user enters selection criteria and reviews the resulting list. The source does not identify a business role or user group.

1. The user enters a material-number range and a maximum row count. The material range is optional; the row-count default is 500.
2. The report rejects a row count less than or equal to zero.
3. It reads matching `MARA` rows, ordered by material number, up to the requested count.
4. If there are no matches, it displays “No materials found” and returns without showing the ALV.
5. If there are matches and `SY-UNAME` is `EXARELAU`, it displays “This report is not available for user EXarelaU” with error styling, but continues to show the ALV.
6. Otherwise, or after the user-specific message, it displays the results in SALV with all SALV functions enabled.

## Data Requirements

| Field | Source | Functional meaning |
| --- | --- | --- |
| `MATNR` | `MARA` | Material number |
| `MTART` | `MARA` | Material type |
| `MATKL` | `MARA` | Material group |
| `MEINS` | `MARA` | Base unit of measure |
| `ERSDA` | `MARA` | Creation date |
| `LAEDA` | `MARA` | Last-change date |
| `LVORM` | `MARA` | Deletion flag |

No additional derivation, conversion, or enrichment is visible in the source.

## Business Rules Observed

- `P_MAX` defaults to 500 and must be positive.
- No upper limit is enforced for `P_MAX`.
- `S_MATNR` may be left empty; an empty range can select any materials up to `P_MAX`.
- Results are ordered by `MATNR` and limited to `P_MAX` rows.
- The user-specific message is informational in control-flow terms: it does not block retrieval or display.
- No matching rows produce an informational-style status message.

## Authorization, Errors, and User Communication

The report contains no explicit authorization check. Authorization to start the report and read the selected material data was not verified. The `EXARELAU` message is not an access control because it follows the database read and execution continues. SALV errors are caught and shown as an error-styled status message. Hard-coded messages are in English; the English text resource file is empty and the selection labels contain placeholder text.

## Acceptance Criteria for the Current Source Behavior

These criteria document the current implementation; they are not confirmation that the behavior is desired.

| ID | Scenario | Expected result |
| --- | --- | --- |
| FD-01 | Matching range, `P_MAX` = 500 | At most 500 matching rows are displayed in ascending material-number order with the seven specified fields. |
| FD-02 | Matching range, `P_MAX` = 1 | At most one matching row is displayed. |
| FD-03 | No matching records | “No materials found” is shown and no ALV is displayed. |
| FD-04 | `P_MAX` is zero or negative | A selection-screen error is raised and retrieval does not proceed. |
| FD-05 | Empty material range | Any matching materials may be returned up to `P_MAX`. |
| FD-06 | Matching records for `EXARELAU` | The user-specific message appears, and the ALV still displays. |
| FD-07 | SALV raises `CX_SALV_MSG` | The exception text is shown as an error-styled status message. |
| FD-08 | User lacks required SAP authorization | Actual behavior is system-dependent and must be validated against role and authorization configuration. |

## Assumptions and Dependencies

- The inspected source is the intended version to document.
- `MARA` and `CL_SALV_TABLE` are available in the target system.
- The report is intended for interactive execution because it calls SALV display.
- No SAP runtime test, role review, or business-process confirmation was performed.

## Open Questions

1. Is user `EXARELAU` intentionally restricted? If yes, should the report stop before any data access, and does the rule apply when there are no matching rows?
2. Should material number be mandatory, and should `P_MAX` have an approved upper bound?
3. Which business roles may run the report, and which material-data authorizations are required?
4. Are the selected fields complete, and how should materials marked for deletion be presented or filtered?
5. Should selection labels and messages be maintained as translatable text elements?
6. Is this package strictly test-only, and should its contents ever be transported?