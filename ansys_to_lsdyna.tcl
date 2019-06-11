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
	variable m_file;
	variable m_width 12;
    
    # Create the GUI
    if [::hm::MyTab::DialogCreate] {
        # Create the frame1
		set frame1 [labelframe $m_recess.frame1 -text "Units" ];
        pack $frame1 -side top -anchor nw -fill x ;
			::hwtk::label $frame1.l1 -text "Mass:"
			::hwtk::savefileentry $frame1.e1 -textvariable [namespace current]::m_file -help "mass unit" -title "select temp file"
			grid $frame1.l1 $frame1.e1 -sticky w -pady 2 -padx 5
			grid configure $frame1.e1 -sticky ew
			
			::hwtk::label $frame1.l1 -text "Length:"
			::hwtk::savefileentry $frame1.e1 -textvariable [namespace current]::m_file -help "temp file name" -title "select temp file"
			grid $frame1.l1 $frame1.e1 -sticky w -pady 2 -padx 5
			grid configure $frame1.e1 -sticky ew
			
			hwtk::combobox $w.lf3.cb -textvariable c3var -state readonly -values $australianCities
			
			grid columnconfigure $frame1 1  -weight 1
			
		# Create the frame2
		set frame2 [labelframe $m_recess.frame2 -text "Command" ];
        pack $frame2 -side top -anchor nw -fill x ;
			#~ ::hwtk::button $frame2.change_name -text "change name" -help "change name" -command { ::hm::MyTab::change_name } 
			::hwtk::button $frame2.output_ansys -text "output ansys" -help "output ansys" -command { ::hm::MyTab::output_ansys } 
			::hwtk::button $frame2.input_lsdyna -text "input lsdyna" -help "input lsdyna" -command { ::hm::MyTab::input_lsdyna } 
			#~ grid $frame2.change_name 
			grid $frame2.output_ansys $frame2.input_lsdyna
		
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
	
	foreach propid $myprop {
		puts "components--$propid"
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
		return [ dict create name $name type $type ]
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
		return
	}
	
	clear_ansys_info
	
	dict for { id value } $m_comp {
		set cardimage [ dict get $value cardimage]
		if { $cardimage=="SHELL181" } {
			*setvalue comps id=$id cardimage="Part"
			set matid [ CreatMat [dict get $value mat]]
			*setvalue comps id=$id materialid={mats $matid}
		} elseif { $cardimage=="SOLID185" } {
			
		} elseif { $cardimage=="MASS21" } {
			
		} elseif { $cardimage=="BEAM188" } {
			
		}
		puts "$id : { $value}"
	}
}

proc ::hm::MyTab::delete_all { type } {
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

proc ::hm::MyTab::CreatMat { mat } {
	set name [ dict get $mat name]
	if { [hm_entityinfo exist materials $name] } {
	} else {
		*createentity mats cardimage=MATL24 name=$name
		*setvalue mats name=$name STATUS=2 90=1
		*setvalue mats id=1 STATUS=1 118=[dict get $mat dens]
		*setvalue mats id=1 STATUS=1 119=[dict get $mat E ]
		*setvalue mats id=1 STATUS=1 120=[dict get $mat Nu ]
	}
	return [hm_getvalue mats name=$matname dataname=id]
}


proc ::hm::MyTab::CreatSecShell { data } {
	set thick [ lindex $data 0 ]
	set t [ string map { . p } $thick ]
	set name [ format "pr_shell_%smm" $t ]
	if { [hm_entityinfo exist properties $name] } {
	} else {
		*createentity props cardimage=SectShll name=$name
		*setvalue mats name=$name STATUS=2 90=1
		*setvalue mats id=1 STATUS=1 118=[dict get $mat dens]
		*setvalue mats id=1 STATUS=1 119=[dict get $mat E ]
		*setvalue mats id=1 STATUS=1 120=[dict get $mat Nu ]
	}
	return [hm_getvalue mats name=$matname dataname=id]
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
