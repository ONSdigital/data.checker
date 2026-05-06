#' @keywords internal
"_PACKAGE"

# Silence R CMD check NOTES for dynamically injected symbols from schema/list2env.
if (getRversion() >= "2.15.1") {
	utils::globalVariables(c(
		".data",
		"allow_duplicates",
		"allow_na",
		"expected_levels",
		"iqr_check",
		"max_date",
		"max_string_length",
		"max_val",
		"max_z_score",
		"min_date",
		"min_string_length",
		"min_val",
		"type",
        "df"
	))
}

## data.checker namespace: start
## data.checker namespace: end
NULL
