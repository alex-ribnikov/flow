set box_list { {0 5050.08 9876.048 8850.24} \
{0 4616.64 9767.52 5050.08} \
{0 987.84 9876.048 4616.64} \
{1031.016 231.84 9876.048 987.84} \
{1031.016 0 9794.652 231.84}}

set color red
gui_show
foreach box $box_list {
    puts $box
    create_gui_shape -layer USER_LAYER_$color -rect $box
}
set_layer_preference USER_LAYER_$color   -color $color
