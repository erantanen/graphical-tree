#! /usr/bin/wish


#-------------------------------------------------------
  proc initVar {} {
	set ::global(canWidth)	450
#	set ::global(canHeight) 50
	set ::global(canHeight) 350
	set ::global(initChild) 20
	set ::global(font)      {Helvetica 18}

   }
#-------------------------------------------------------
  proc main {} {
	initVar
	buildGui
	buildCanvas
	entry_layer_num
   }
#---------------------------------------------------------
  proc buildGui {} {
	menu .menubar  
	. config -menu .menubar 
	foreach m {file  help} {
	  set $m [menu .menubar.m$m -tearoff 0]
	  .menubar add cascade -label $m -menu .menubar.m$m }

	$file add command  -label Quit  -command exit
    $help add command  -label Help  -command help_diag
    $help add command  -label About -command about_diag

	#---------------------------------



	label .msg1  -justify left -text\
        	 "This window displays variations of:"

	label .msg2 -font $::global(font) -foreground blue\
				 -wraplength 4i\
				 -justify left -text\
			 "A Tree Graph"

	pack .msg1 .msg2 -side top
   }

#----------------------------------------------------------

  proc buildCanvas {} {
	canvas .c -width  $::global(canWidth)\
		  -height $::global(canHeight)\
		  -relief sunken -borderwidth 2

	pack .c -side top -fill x
   }

#----------------------------------------------------------
#------------------- dialog boxes -------------------------

#-------- The About window --------
 proc about_diag {} {
    tk_messageBox -type ok\
    		      -title About\
				  -message \
		 		 "Programmed by\
				\nEd Rantanen,\
				\nApril 2002.\
			\nrantanen@intrepid.net" \
  }

#-------- The Help window --------

  proc help_diag {} {
    tk_messageBox -type ok\
    		      -title Help\
		      -message \
	"There is no help\
     \navalible to the user\
	\nat this time"
  }

#----------------------------------------------------------
#----------- entry / checkbox area ------------------------

  proc entry_layer_num {} {

	 frame .vert 
	 label .vert.lable -text "Number of Verticies" -bd 4
         entry .vert.entry -textvariable ::global(child) -relief sunken -width 10
	 pack .vert.lable .vert.entry

	#frame .layer
        #label .layer.lable -text "Number of Layers" -bd 4
	# .layer.hold  -text  "0" 
	#pack .layer.lable .layer.hold
       
       
	pack .vert -side  left -fill x
	#pack .layer -side right -fill x
	 
	 bind .vert.entry <Return> update_childrn
	 
	 radiobutton .radio  -text "A one layer Tree"\
				-variable ::global(tree_layer)\
				-value 1
	radiobutton  .radio1  -text "A Skewed Tree"\
                                -variable ::global(tree_layer)\
				-value 2
       radiobutton  .radio2  -text "A Binary Tree"\
                                -variable ::global(tree_layer)\
                                -value 3


	pack .radio
	pack .radio1
	pack .radio2 
   }

#----------------------------------------------------------
#------ find number of layers ----------------------------
  proc w_layers {child} {

        set layer 1 
        set t_sum_of_tree 0 

     while {$t_sum_of_tree < $child} {
         set t_sum_of_tree [expr pow(2,$layer) - 1]
	 incr layer
      }
	
      set ::global(layer)    [expr $layer - 1]
  }

#----------------------------------------------------------
#--- udpdate numbre of children drawn on canvas ----------

  proc update_childrn {} {
	
	w_layers $::global(child)
	draw_childrn
    }


#---------------------------------------------
#------- builds single layer tree ------------

    proc s_layer_tree {} {
        set xs [expr $::global(canWidth)/2]
        set ys 10

           set node 1

             set xf [expr $::global(canWidth)/$::global(layer)]
             set yf [expr $::global(canHeight)/$::global(layer)]

          while {$::global(child) > $node} {
                 .c creat line  $xs $ys  $xf  $yf  -width 1\
                                                   -fill black\
                                                   -tag "vert"
                 .c create text $xf [expr $yf + 7]\
                                        -text [expr $node + 1]\
                                        -tag "vert"

             incr xf 13
             incr node
          }
       }


#---------------------------------------------
#----- builds squewed multi layer tree -------

    proc m_layer_tree {} {
		
	set in_child $::global(child)
	set id 1
	set layer 1 
   #------------------------------------------
   #-------build array for children ----------

          while {$::global(layer) > $layer} {
				  	
			set layer_sum [expr pow(2,$layer)]	
			set node_space [expr $layer_sum + 1]


  			if {$in_child > $layer_sum} {
                                set in_child [expr $in_child - $layer_sum]
                                regsub {\.[0-9]} $in_child {} in_child
                                        for {set i 1} {$layer_sum >= $i} {incr i} {
                                          set node_sep [expr $::global(canWidth)/$node_space]
                                          regsub {\.[0-9]*} $node_sep {} node_sep
                                          set x($id) "$layer $node_sep"
                                                incr id
                                        }
				incr layer

                        }

			if {$in_child <  $layer_sum} {
                                        for {set i 0} {$in_child > $i} {incr i} {
                                          set node_sep [expr $::global(canWidth)/$node_space]
                                          regsub {\.[0-9]*} $node_sep {} node_sep
                                          set x($id) "$layer $node_sep"
                                                incr id
                                        }
				incr layer
                        }

			if {$in_child == $layer_sum} { 
                                set in_child [expr $in_child - $layer_sum]
                                regsub {\.[0-9]} $in_child {} in_child
					for {set i 1} {$layer_sum >= $i} {incr i} {
                                 	  set node_sep [expr $::global(canWidth)/$node_space]
                                 	  regsub {\.[0-9]*} $node_sep {} node_sep
					  set x($id) "$layer $node_sep"
					   incr id
					}
				incr layer
                       }
		 #puts   "array [array get x]"

          }
    #--------------------------------------------------
    #----- time to do something with array -----------

    #-------------------------------------------
        set xs [expr $::global(canWidth)/2]
        set ys 5
	set new_id 1
	set next_node 1
	set x_node_dis 0
	set y_node_dis 0
        set yf [expr $::global(canHeight)/$::global(layer)]
    #-------------------------------------------
	
	while {$::global(child) > $new_id} {
		
			

		 if {$next_node == [lindex [lindex [array get x $new_id] 1] 0]} {
		      		
		   set x_node_dis  [expr $x_node_dis + [lindex [lindex [array get x $new_id] 1] 1]]
		      set xf $x_node_dis
		      	
		   .c creat line  $xs $ys  $xf  $yf  -width 1\
                                                   -fill black\
                                                   -tag "vert"
                   .c create text $xf [expr $yf + 7]\
                                        -text [expr $new_id + 1]\
                                        -tag "vert"
			#puts $new_id
		   incr new_id
			#puts " $ys $yf $xs $xf"
			 

		} else { 
		   set ys $yf
		   set xs $xf 

		   #puts $y_node_dis

		   set yf [expr $yf + 70]
 	
		   set x_node_dis  [expr $x_node_dis + [lindex [lindex [array get x $new_id] 1] 1]]
                      set xf $x_node_dis

                   .c creat line  $xs $ys  $xf  $yf  -width 1\
                                                   -fill black\
                                                   -tag "vert"
                   .c create text $xf [expr $yf + 7]\
                                        -text [expr $new_id + 1]\
                                        -tag "vert"
			#puts " $ys $yf $xs $xf else"



		   incr next_node
		   incr new_id 
		   set x_node_dis 0	}
	}



       }
#----------------------------------------------------

  proc draw_childrn {} {
	
	
	.c configure -background  #FFFFFF

	foreach vert [.c find withtag "vert"] { .c delete  $vert  }
      
	if {$::global(child) == 0} {
		.c create text [expr $::global(canWidth)/2] 70 \
				 -text "There has to be at least\
				 		\n one node to a Tree"\
				 -font $::global(font)\
				 -tag "vert"
	} elseif {$::global(child) == 1} {
                .c create text [expr $::global(canWidth)/2] 70 \
                                 -text "A tree with 1 node is a truly rooted tree."\
                                 -font $::global(font)\
                                 -tag "vert"
				
		  set x	[expr $::global(canWidth)/2]
		  set y 10

		.c creat oval  $x  $y [expr $x + 7] [expr $y + 7]  -width 1\
                                                  -fill green\
                                                  -tag "vert"
		
	} elseif {$::global(tree_layer) == 1} {
		 s_layer_tree
	
	} elseif  {$::global(tree_layer) == 2} {
		m_layer_tree
	} else {
		         .c create text [expr $::global(canWidth)/2] 70 \
                                 -text "Danger, Danger, Will Robinson\
                                      \nthe binary tree is unstable. "\
                                 -font $::global(font)\
                                 -tag "vert"



	}

   }


main 







