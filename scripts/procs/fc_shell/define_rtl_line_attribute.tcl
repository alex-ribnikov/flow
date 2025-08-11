
define_derived_user_attribute \
	  -name rtl_line \
	  -classes {timing_point} \
	  -type string \
	  -get_command {
		if {[get_attribute %object object.object_class]=="pin"} {
			get_cross_probing_info [get_cells -of [get_attribute %object object]] -unique_source
		} elseif {[get_attribute %object object.object_class]=="port"} {
			get_cross_probing_info [get_attribute %object object] -unique_source
		} else {
			return " "
		}
	      }

