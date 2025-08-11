BEGIN { 
  st_flag = 0
  nd_flag = 0
  nd_pin_flag = 1
  nd = "not empty"
  counter = 0
  st = "empty"
}
{
  counter++
  if ($1 ~ st) {st_pin = $1};
  if ($1 ~ nd) {  
      nd_pin_tmp = $1 ;
#      print "t: "nd" : "nd_pin_tmp
  }
  if ($1 == "Startpoint:"){
    st = $2;
    st_flag = 1
    nd_flag = 0
  }
  if ($1 == "Endpoint:"){
    nd = $2;
    nd_pin = ""
    st_flag = 0
    nd_flag = 1
  }
  if ($1 == "Clock:" && st_flag) {st_clk = $3}
  if ($0 ~ /clocked/ && st_flag) {st_clk = substr($NF,1,length($NF)-1)}
  if ($1 == "Clock:" && nd_flag) {nd_clk = $3}
  if ($0 ~ /clocked/ && nd_flag) {nd_clk = substr($NF,1,length($NF)-1)}
  if ($0 ~ /data arrival time/ && nd_pin_flag && length(nd_pin_tmp)>0 ){ nd_pin = nd_pin_tmp }
  if ($0 ~ /data required time/ ){ nd_pin_flag = 0 }
  
  
  if ($1 == "Slack:="){
    slack = $2
    print slack" | "nd" ("nd_clk") | " st" ("st_clk")"
  }else if ($1 == "slack" && $2 == "(VIOLATED)" ){
    if (length(st_pin)>0 && st_pin != "empty") {st=st_pin}
    if (length(nd_pin)>0) {nd=nd_pin}
    slack = $NF
    print slack" | "nd" ("nd_clk") | " st" ("st_clk")"
    nd_pin_flag = 1
    nd_pin_tmp = ""
    st_pin = "empty"
  }
}
