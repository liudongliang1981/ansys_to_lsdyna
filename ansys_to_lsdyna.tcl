# HWVERSION_2017.1_Apr 12 2017_22:30:32
#################################################################
# File      : hm_tab.tcl
# Date      : June 7, 2007
# Created by: Liu Dongliang
# Purpose   : Creates a GUI to help manage test gauges
#################################################################
package require hwt;
package require hwtk;

catch {namespace delete ::hm::MyTab }

namespace eval ::hm::MyTab {
    variable m_title "MyTab";
	variable m_recess ".m_MyTab";
	variable m_file "tempfile";
	variable m_get_ansys_ok 0;
	variable m_comp {};
}

#################################################################
proc ::hm::MyTab::Answer { question type } {
	return [tk_messageBox \
			-title "Question"\
			-icon info \
			-message "$question" \
			-type $type]
}
#################################################################
proc ::hm::MyTab::ValidateName { name } {
	return [ regexp {^[a-zA-Z]+[0-9a-zA-Z_-]*$} $name ] 
}

#################################################################
proc ::hm::MyTab::DialogCreate { args } {
    # Purpose:  Creates the tab and the master frame
    # Args:
    # Returns:  1 for success. 0 if the tab already exists.
    # Notes:

    variable m_recess;
    variable m_title;

    set alltabs [hm_framework getalltabs];

    if {[lsearch $alltabs $m_title] != -1} {
        hm_framework activatetab "$m_title";

        return 0;
    } else {
        catch {destroy $m_recess};

        set m_recess [frame $m_recess -padx 7 -pady 7];

        hm_framework addtab "$m_title" $m_recess ::hm::MyTab::Resize ::hm::MyTab::TearDownWindow;

        ::hwt::AddPadding $m_recess -side top height [hwt::DluHeight 4] width [hwt::DluWidth 0];

        return 1;
    }
}

#################################################################
proc ::hm::MyTab::Resize { args } {
    # Purpose:  Resize the tab
    # Args:
    # Returns:  Size to resize the tab to
    # Notes:

    return 358;
}

#################################################################
proc ::hm::MyTab::TearDownWindow { flag args } {
    # Purpose:  Destroy the tab and frame when the GUI is closed.
    # Args:     flag - hm_framework flag that is passed to tell
    #           the proc when it is being called.
    # Returns:
    # Notes:

    variable m_recess;
    variable m_title;

    if {$flag == "after_deactivate"} {
        catch {::hm::MyTab::UnsetCallbacks};
        catch {destroy $m_recess };
        hm_framework removetab "$m_title";

        focus -force $::HM_Framework::p_hm_container;
    }
}

#################################################################
proc ::hm::MyTab::SetCallbacks { args } {
    # Purpose:  Defines the callbacks
    # Args:
    # Returns:
    # Notes:

    #~ ::hwt::AddCallback *readfile ::hm::MyTab::New;
    #~ ::hwt::AddCallback *deletemodel ::hm::MyTab::New;
	
    #~ ::hwt::AddCallback *deletemark ::hm::MyTab::RemoveSystem before
}

#################################################################
proc ::hm::MyTab::UnsetCallbacks { args } {
    # Purpose:  Undefines the callbacks when the tab is closed
    # Args:
    # Returns:
    # Notes:

    #~ ::hwt::RemoveCallback *readfile ::hm::MyTab::New;
    #~ ::hwt::RemoveCallback *deletemodel ::hm::MyTab::New;
	
    #~ ::hwt::RemoveCallback *deletemark ::hm::MyTab::RemoveSystem;
}

#################################################################

#################################################################
proc ::hm::MyTab::Main { args } {
    # Purpose:  Creates the GUI and calls the routine to populate
    #           the table.
    # Args:
    # Returns:
    # Notes:
	
    variable m_recess;
	variable m_width 12;
	
	variable m_mass_unit "ton";
	variable m_mass_factor 1;
	variable m_length_unit "mm";
	variable m_length_factor 1;
	variable m_time_unit "s";
	variable m_time_factor 1;
    
    # Create the GUI
    if [::hm::MyTab::DialogCreate] {
        # Create the frame1
		set frame1 [labelframe $m_recess.frame1 -text "Units and scale factor" ];
        pack $frame1 -side top -anchor nw -fill x ;
			::hwtk::label $frame1.l1 -text "Mass:"
			hwtk::entry $frame1.e11 -textvariable [namespace current]::m_mass_factor -inputtype double 
			hwtk::combobox $frame1.e12 -textvariable [namespace current]::m_mass_unit -state readonly -values {ton kg}
			grid $frame1.l1 $frame1.e11 $frame1.e12 -sticky w -pady 2 -padx 5
			grid configure $frame1.e11 -sticky ew
			grid configure $frame1.e12 -sticky ew
			
			::hwtk::label $frame1.l2 -text "Length:"
			hwtk::entry $frame1.e21 -textvariable [namespace current]::m_length_factor -inputtype double
			hwtk::combobox $frame1.e22 -textvariable [namespace current]::m_length_unit -state readonly -values {mm m}
			grid $frame1.l2 $frame1.e21 $frame1.e22 -sticky w -pady 2 -padx 5
			grid configure $frame1.e21 -sticky ew
			grid configure $frame1.e22 -sticky ew
			
			::hwtk::label $frame1.l3 -text "Time:"
			hwtk::entry $frame1.e31 -textvariable [namespace current]::m_time_factor -inputtype double
			hwtk::combobox $frame1.e32 -textvariable [namespace current]::m_time_unit -state readonly -values {s ms}
			grid $frame1.l3 $frame1.e31 $frame1.e32 -sticky w -pady 2 -padx 5
			grid configure $frame1.e31 -sticky ew
			grid configure $frame1.e32 -sticky ew
			
			grid columnconfigure $frame1 1  -weight 1
			grid columnconfigure $frame1 2  -weight 1
			
		# Create the frame2
		set frame2 [labelframe $m_recess.frame2 -text "Command" ];
        pack $frame2 -side top -anchor nw -fill x ;
			#~ ::hwtk::button $frame2.change_name -text "change name" -help "change name" -command { ::hm::MyTab::change_name } 
			::hwtk::button $frame2.add_node3_comp -text "add node3 by comp" -help "add node3 by comp" -command { ::hm::MyTab::add_node3_for_lsdyna_comp }
			::hwtk::button $frame2.add_node3_all -text "add node3 by elem" -help "add node3 by elem" -command { ::hm::MyTab::add_node3_for_lsdyna_elem }
			::hwtk::button $frame2.output_ansys -text "output ansys" -help "output ansys" -command { ::hm::MyTab::output_ansys }
			::hwtk::button $frame2.input_lsdyna -text "input lsdyna" -help "input lsdyna" -command { ::hm::MyTab::input_lsdyna }
			#~ grid $frame2.change_name 
			grid $frame2.add_node3_comp  $frame2.add_node3_all -sticky ew
			grid $frame2.output_ansys $frame2.input_lsdyna -sticky ew
			
			grid columnconfigure $frame2 "all" -weight 1
			
		# Create the frame4
        set frame4 [frame $m_recess.frame4];
        pack $frame4 -side bottom -anchor nw -fill x;
			button $frame4.close -text "Close" -width $m_width -command ::hm::MyTab::Close 
			pack $frame4.close -side right
		::hm::MyTab::SetCallbacks;
    }
}

#################################################################
proc ::hm::MyTab::Close { args } {
	variable m_title;
	
	set ans [ Answer "Are you sure you want to leave?" okcancel ]
	if { $ans == "cancel" } { return }
	
	hm_framework removetab "$m_title";
	TearDownWindow after_deactivate;
}

proc ::hm::MyTab::Error { msg } {
	variable m_title;
	
	set ans [ Answer "Error : $msg" ok ]
	
	hm_framework removetab "$m_title";
	TearDownWindow after_deactivate;
}

#################################################################
# rename
proc ::hm::MyTab::do_change_name { proptype pre } {
	*createmark $proptype 1 all
	set myprop [ hm_getmark $proptype 1 ]
	*clearmark $proptype 1
	
	foreach propid $myprop {
		set propname [ hm_getcollectorname $proptype $propid ]
		puts "$proptype : ( $propid , $propname )"
		#~ [ regexp {[a-zA-Z]+[0-9a-zA-Z_-]*} $input name ]
		set newpropname [ string map {. p " " "" "\n" "" "\t" "" "\r" "" * "" ^ "" % "" "\$" "" "#" "" ! "" ~ "" "`" "" "@" "" & "" , "" < "" > "" "(" "" ")" "" "{" "" "}" "" "|" "" "\\" "" / "" ? "" "'" "" "\"" "" ";" "" "[" "" "]" ""} $propname ]
		if { [ string match {[0-9]*} $newpropname ] } {
			set newpropname "${pre}_${newpropname}"
		}
		if {[string equal $propname $newpropname]} {
			continue
		}
		if { [ hm_entityinfo exist $proptype $newpropname ] } {
			set newpropname [ hm_getincrementalname $proptype $newpropname 1 ] 
		}
		*renamecollector $proptype $propname $newpropname
		puts "rename $proptype : $propname  --> $newpropname"
	}
}

proc ::hm::MyTab::change_name { args } {
	##
	set state [ hm_commandfilestate 0]
	hm_blockmessages 1
	##
	
	do_change_name components T
	#~ do_change_name properties pr
	#~ do_change_name materials mat
	do_change_name sets s
	#~ do_change_name loadsteps ls
	#~ do_change_name loadcols l
	#~ do_change_name assemblies a
	#~ do_change_name beamsects sec
	
	##
	hm_commandfilestate $state
	hm_blockmessages 0
	##
}

#################################################################
proc ::hm::MyTab::add_node3_for_lsdyna_comp { } {
	##
	set state [ hm_commandfilestate 0]
	hm_blockmessages 1
	*retainmarkselections 0
	##
	if { [ is_template ansys] } {
		*createmarkpanel comps 1 "select comps..."
		set comps [ hm_getmark comps 1 ]
		*clearmark comps 1
		if { $comps != "" } {
			*entityhighlighting 0
			DoAdd_3_node_to_beam_for_lsdyna_comp $comps
			*entityhighlighting 1
		}
	} else {
		hm_errormessage "Please make sure in ansys template now!"
	}
	##
	hm_commandfilestate $state
	hm_blockmessages 0
	##
}

proc ::hm::MyTab::DoAdd_3_node_to_beam_for_lsdyna_comp { comp } {
	eval *createmark elems 1 "by comp id" $comp
	set beams [ hm_getmark elems 1 ]
	*clearmark elems 1
	
	DoAdd_3_node_to_beam_for_lsdyna_elem $beams
}


proc ::hm::MyTab::add_node3_for_lsdyna_elem { } {
	##
	set state [ hm_commandfilestate 0]
	hm_blockmessages 1
	*retainmarkselections 0
	##
	if { [ is_template ansys] } {
		*createmarkpanel elems 1 "select beam elems..."
		set elems [ hm_getmark elems 1 ]
		*clearmark elems 1
		if { $elems != "" } {
			*entityhighlighting 0
			DoAdd_3_node_to_beam_for_lsdyna_elem $elems
			*entityhighlighting 1
		}
	} else {
		hm_errormessage "Please make sure in ansys template now!"
	}
	##
	hm_commandfilestate $state
	hm_blockmessages 0
	##
}

proc ::hm::MyTab::DoAdd_3_node_to_beam_for_lsdyna_elem {  elems } {
	puts "add node3 for [llength $elems]  beam elements"
	set temp [ time {
			foreach eid $elems {
				add_n3_to_beam $eid 1
			}
		} ]
	puts [format "It took %.3f seconds."  [expr [lindex $temp 0] / 1000000.0] ]
}

proc ::hm::MyTab::add_n3_to_beam { id y_dir } {
	if { [ hm_getvalue elems id=$id dataname=config ] == 60 &&  [ hm_getvalue elems id=$id dataname=directionnodeused] == 0 } { 
		if { $y_dir == 1 } {
			set vx [ hm_getvalue elems id=$id dataname=localyx ]
			set vy [ hm_getvalue elems id=$id dataname=localyy ]
			set vz [ hm_getvalue elems id=$id dataname=localyz ]
		} else {
			set vx [ hm_getvalue elems id=$id dataname=localzx ]
			set vy [ hm_getvalue elems id=$id dataname=localzy ]
			set vz [ hm_getvalue elems id=$id dataname=localzz ]
		}
		set v [list $vx $vy $vz ]
		set node1 [ hm_getvalue elems id=$id dataname=node1 ] 
		set node1_p [ hm_getvalue nodes id=$node1 dataname=coordinates ]
		set n3x [ expr [lindex $node1_p 0]+ 10*$vx]
		set n3y [ expr [lindex $node1_p 1]+ 10*$vy]
		set n3z [ expr [lindex $node1_p 2]+ 10*$vz]
		set node3 [ CreateNode [list $n3x $n3y $n3z ] ]
		*createmark elements 1 $id
		*createvector 1 1 0 0
		*barelementupdatewithoffsets 1 0 0 1 0 0 0 0 "" 1 $node3 0 0 0 0 0 0 0 0 0 0 0
		*createmark nodes 1 $node3
		*nodemarkcleartempmark 1
	}
}

proc ::hm::MyTab::CreateNode { pos } {
	eval *createnode $pos 0 0 0
	set ans [TheLast nodes];
	set ans;
}

proc ::hm::MyTab::TheLast { type } {
	*createmark $type 1 -1
	set id [ hm_getmark $type 1]
	*clearmark $type 1
	set id;
}

#################################################################
## get ansys information
proc ::hm::MyTab::do_get_ansys { args } {
	variable m_get_ansys_ok;
	variable m_comp;
	
	set m_comp {}
	set m_get_ansys_ok 0
	
	set proptype components

	*createmark $proptype 1 all
	set myprop [ hm_getmark $proptype 1 ]
	*clearmark $proptype 1
	puts  -nonewline "components"
	foreach propid $myprop {
		puts -nonewline " \[$propid\]"
		set name [ hm_getvalue comps id=$propid dataname=name ]
		set sensorid [ hm_getvalue comps id=$propid dataname=3081 ]
		set propertyid [ hm_getvalue comps id=$propid dataname=propertyid ]
		set materialid [ hm_getvalue comps id=$propid dataname=materialid ]
			
		if { [ string equal $sensorid "0" ] } {		
			set cardimage "unsupported"
		} else {
			set cardimage [ hm_getvalue sensors id=$sensorid dataname=cardimage ]
		}
		
		if { [ string equal $cardimage "SHELL181" ] } {
			set thickness [ hm_getvalue props id=$propertyid dataname=136 ]
			set mat [ get_mat $materialid ]
			dict set  m_comp $propid [ dict create name $name cardimage $cardimage mat $mat thick $thickness]
		} elseif { [ string equal $cardimage "MASS21" ] } {
			set mass [ hm_getvalue props id=$propertyid dataname=136 ]
			dict set  m_comp $propid [ dict create name $name cardimage $cardimage mass $mass]
		} elseif { [ string equal $cardimage "BEAM188" ] } {
			set mat [ get_mat $materialid ]
			set sec [ get_sec $propertyid ]
			dict set  m_comp $propid [ dict create name $name cardimage $cardimage mat $mat sec $sec]
		} elseif { [ string equal $cardimage "SOLID185" ] } {
			set mat [ get_mat $materialid ]
			dict set  m_comp $propid [ dict create name $name cardimage $cardimage mat $mat ]
		} else {
			puts "$name $cardimage unsupported"
		}
	}
	
	if [ dict size $m_comp] {
		set m_get_ansys_ok 1
	}
	puts ""
}

proc ::hm::MyTab::get_mat { materialid } {
	set matname [  hm_getvalue mats id=$materialid dataname=name ]
	set cardimage [ hm_getvalue mats id=$materialid dataname=cardimage ] 
	if { [ string equal $cardimage "MATERIAL" ] } {
		set dens [ hm_getvalue mats id=$materialid dataname=2619 ]
		set ex [ hm_getvalue mats id=$materialid dataname=2645 ]
		set nuxy [ hm_getvalue mats id=$materialid dataname=2608 ]
	} elseif { [ string equal $cardimage "MPDATA" ] } {
		set dens [ hm_getvalue mats id=$materialid dataname=512 ]
		set ex [ hm_getvalue mats id=$materialid dataname=516 ]
		set nuxy [ hm_getvalue mats id=$materialid dataname=608 ]
	}
	return [ dict create name $matname dens $dens E  $ex Nu $nuxy ]
}

proc ::hm::MyTab::get_sec { propertyid } {
	set name [ hm_getvalue props id=$propertyid dataname=name ] 
	set secid [ hm_getvalue props id=$propertyid dataname=3007 ]
	set type [ hm_getvalue beamsects id=$secid dataname=sectiontype ]
	if { [ string equal $type "46" ] } {
		set r [ hm_getvalue beamsects id=$secid dataname=beamsect_dim1 ]
		return [ dict create name $name type $type r $r ]
	} elseif { [ string equal $type "49" ] } {
		set a [ hm_getvalue beamsects id=$secid dataname=beamsect_dim1 ]
		set b [ hm_getvalue beamsects id=$secid dataname=beamsect_dim2 ]
		set t1 [ hm_getvalue beamsects id=$secid dataname=beamsect_dim3 ]
		set t2 [ hm_getvalue beamsects id=$secid dataname=beamsect_dim4 ]
		set t3 [ hm_getvalue beamsects id=$secid dataname=beamsect_dim5 ]
		set t4 [ hm_getvalue beamsects id=$secid dataname=beamsect_dim6 ]
		return [ dict create name $name type $type a $a b $b t1 $t1 t2 $t2 t3 $t3 t4 $t4 ]
	} else {
		set r [ hm_getvalue beamsects id=$secid dataname=beamsect_dim1 ]
		return [ dict create name $name type $type r $r ]
	}
}

proc ::hm::MyTab::get_spring { propertyid } {
	set name [ hm_getvalue props id=$propertyid dataname=name ] 
	set spring [ hm_getvalue props id=$propertyid dataname=136 ]
	return [ dict create name $name spring $spring]
}

#################################################################
## convert information to lsdyna
proc ::hm::MyTab::do_to_lsdyna { args } {
	variable m_get_ansys_ok;
	variable m_comp;
	
	if { $m_get_ansys_ok==0 } {
		hm_errormessage "Please make output ansys first!"
		return 0
	}
	
	clear_ansys_info
	
	puts  -nonewline "processing component "
	dict for { id value } $m_comp {
		puts -nonewline " \[$id\]"
		*setvalue comps id=$id cardimage="Part"
		set cardimage [ dict get $value cardimage]
		if { $cardimage=="SHELL181" } {
			set matid [ CreatMat [dict get $value mat] "MATL24" ]
			*setvalue comps id=$id materialid={mats $matid}
			set propid [ CreatSecShell [dict get $value thick]]
			*setvalue comps id=$id propertyid={props $propid}
		} elseif { $cardimage=="SOLID185" } {
			set matid [ CreatMat [dict get $value mat] "MATL24" ]]
			*setvalue comps id=$id materialid={mats $matid}
			set propid [ CreateSecSolid 1 ]
			*setvalue comps id=$id propertyid={props $propid}
		} elseif { $cardimage=="MASS21" } {
			UpdateMass $id  [dict get $value mass]
			*setvalue comps id=$id propertyid={props 0}
			*setvalue comps id=$id materialid={mats 0}
		} elseif { $cardimage=="BEAM188" } {
			set sectype [dict get $value sec type]
			if { $sectype == "46" } {
				set matid [ CreatMat [dict get $value mat ] "MATL100" 2526 2527 2528 ]]
				set propid [ CreatSecBeam  [dict get $value sec] ]
			} elseif { $sectype == "49" } {
				set matid [ CreatMat [dict get $value mat ] "MATL28" ]]
				set propid [ CreatSecBeam  [dict get $value sec] ]
			} else {
				set matid [ CreatMat [dict get $value mat ] "MATL1" ]]
				set propid [ CreatSecBeam  [dict get $value sec] ]
			}
			*setvalue comps id=$id materialid={mats $matid}
			*setvalue comps id=$id propertyid={props $propid}
		} else {
			puts "skip $id : { $value}"
		}
	}
	return 1
}

proc ::hm::MyTab::delete_all { type } {
	puts "removing all $type"
	*createmark $type 1 "all"
	catch { *deletemark $type 1 }
}

proc ::hm::MyTab::clear_ansys_info { } {
	delete_all beamsects
	delete_all beamsectcols
	delete_all materials
	delete_all properties
	delete_all sensors
	delete_all loadcols
	delete_all loadsteps
	delete_all cards

	*clearmarkall
}

proc ::hm::MyTab::CreatMat { mat {type "MATL24"} { densid 118} { Eid 119} {Nuid 120} } {
	variable m_mass_factor;
	variable m_length_factor;
	variable m_time_factor;
	
	set name [ dict get $mat name]
	if { [hm_entityinfo exist materials $name] } {
	} else {
		set dens [ expr 1.0 * [dict get $mat dens] * $m_mass_factor / $m_length_factor ** 3 ]
		set E [ expr 1.0 * [dict get $mat E] * $m_mass_factor / $m_length_factor /$m_time_factor ** 2 ]
		set Nu [dict get $mat Nu ]
		*createentity mats cardimage=$type name=$name
		*setvalue mats name=$name STATUS=2 90=1
		*setvalue mats name=$name STATUS=1 $densid=$dens
		*setvalue mats name=$name STATUS=1 $Eid=$E
		*setvalue mats name=$name STATUS=1 $Nuid=$Nu
	}
	return [hm_getvalue mats name=$name dataname=id]
}

proc ::hm::MyTab::CreatSecShell { data } {
	variable m_length_unit;
	variable m_length_factor;
	
	set thick [expr [ lindex $data 0 ] * $m_length_factor ]
	set t [ string map { . p } $thick ]
	set name [ format "pr_shell_%s%s" $t $m_length_unit ]
	if { [hm_entityinfo exist properties $name] } {
	} else {
		*createentity props cardimage=SectShll name=$name
		*setvalue props name=$name STATUS=1 399=2
		*setvalue props name=$name STATUS=1 402=[expr 5.0/6.0]
		*setvalue props name=$name STATUS=1 427=5
		*setvalue props name=$name STATUS=1 428=1
		*setvalue props name=$name STATUS=1 431=$thick
	}
	return [hm_getvalue props name=$name dataname=id]
}

proc ::hm::MyTab::CreateSecSolid { {elform 1} } {
	set name [ format "pr_solid_%s" $elform ]
	if { [hm_entityinfo exist properties $name] } {
	} else {
		*createentity props cardimage=SectSld name=$name
		*setvalue props name=$name STATUS=1 399=$elform
	}
	return [hm_getvalue props name=$name dataname=id]
}

proc ::hm::MyTab::CreatSecBeam { data } {
	variable m_length_unit;
	variable m_length_factor;
		
	set sectype [dict get $data type]
	if { $sectype == "46" } {
		set r [expr [dict get $data r] * $m_length_factor ]
		set name [ string map {. p} [ format "pr_beam_d%s%s" [expr 2*$r] $m_length_unit ] ]
		set elform 9
		set shrf 1
		set qr 1
		set cst 1		
	} elseif { $sectype == "49" } {
		set a [expr [dict get $data a] * $m_length_factor ]
		set b [expr [dict get $data b] * $m_length_factor ]
		set t1 [expr [dict get $data t1] * $m_length_factor ]
		set t2 [expr [dict get $data t2] * $m_length_factor ]
		set t3 [expr [dict get $data t3] * $m_length_factor ]
		set t4 [expr [dict get $data t4] * $m_length_factor ]
		set name [ string map {. p} [ format "pr_beam_box%s-%s-%s%s" $a $b $t1 $m_length_unit ] ]
		set elform 2
		set shrf 1
		set qr 2
		set cst 0
		
	} else {
		set r [expr [dict get $data r] * $m_length_factor ]
		set name [ string map {. p} [ format "pr_beam_d%s%s" [expr 2*$r] $m_length_unit ] ]
		set elform 1
		set shrf 1
		set qr 1
		set cst 1
	}
	
	if { [hm_entityinfo exist properties $name] } {
	} else {
		*createentity props cardimage=SectBeam name=$name
		*setvalue props name=$name STATUS=1 399=$elform
		*setvalue props name=$name STATUS=1 402=$shrf
		*setvalue props name=$name STATUS=1 403=$cst
		*setvalue props name=$name STATUS=1 429=$qr
		if { $elform == 1 || $elform == 9 } {
			*setvalue props name=$name STATUS=1 723=$r
			*setvalue props name=$name STATUS=1 724=$r
			*setvalue props name=$name STATUS=1 725=0
			*setvalue props name=$name STATUS=1 726=0
		} elseif { $elform == 2 } {
			*setvalue props name=$name STATUS=2 2023=2
			*setvalue props name=$name STATUS=2 2039="SECTION_19"
			*setvalue props name=$name STATUS=1 2031=$a
			*setvalue props name=$name STATUS=1 2032=$b
			*setvalue props name=$name STATUS=1 2033=$t1
			*setvalue props name=$name STATUS=1 2034=$t2
			*setvalue props name=$name STATUS=1 2035=$t3
			*setvalue props name=$name STATUS=1 2036=$t4			
		} 
	}
	return [hm_getvalue props name=$name dataname=id]
}

proc ::hm::MyTab::UpdateMass { id data } {
	variable m_mass_factor;
	
	set mass [ expr [lindex $data 0] * $m_mass_factor]
	*createmark elems 1 "by comp id" $id
	*massmagnitudeupdate 1 $mass 2
	*clearmark elems 1
}

proc ::hm::MyTab::UpdateElemType { } {
	puts "updating elements type..."
	*elementtype 1 1
	*elementtype 3 1
	*elementtype 5 2
	*elementtype 21 1
	*elementtype 61 1
	*elementtype 60 1
	*elementtype 103 1
	*elementtype 104 1
	*elementtype 204 1
	*elementtype 206 1
	*elementtype 208 1
	*elementtype 210 1
	*elementtype 56 1
	*elementtype 2 1
	*elementtype 23 1
	*elementtype 24 1
	*elementtype 63 1
	*elementtype 57 1
	*elementtype 70 1
	*elementtype 106 1
	*elementtype 108 1
	*elementtype 215 1
	*elementtype 220 1
	*elementtype 205 1
	*elementtype 213 1
	*createmark elements 1 "all"
	catch {*elementsettypes 1}
}
##########################################################################
### convert ansys to lsdyna
proc ::hm::MyTab::output_ansys { args } {
	
	##
	set state [ hm_commandfilestate 0]
	hm_blockmessages 1
	##
	if { [ is_template ansys] } {	
		do_get_ansys	
	} else {
		hm_errormessage "Please make sure in ansys template now!"
	}
	##
	hm_commandfilestate $state
	hm_blockmessages 0
	##
}

proc ::hm::MyTab::input_lsdyna { args } {
	
	##
	set state [ hm_commandfilestate 0]
	hm_blockmessages 1
	##
	if { [ is_template "LS-Dyna"] } {	
		do_to_lsdyna
		UpdateElemType
	} else {
		hm_errormessage "Please make sure in ls-dyna template now!"
	}
	##
	hm_commandfilestate $state
	hm_blockmessages 0
	##
}

proc ::hm::MyTab::is_template { name } {
	return [ string equal -nocase $name [ hm_info templatecodename]]
}
##########################################################################
if [ catch {::hm::MyTab::Main} err] {
	::hm::MyTab::Error $err
}
