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
    variable m_split;
    variable m_tree;
    variable m_pa;
	
    # Create the GUI
    if [::hm::MyTab::DialogCreate] {
        # Create the frame1
		set frame1 [labelframe $m_recess.frame1 -text "Parameter" ];
        pack $frame1 -side top -anchor nw -fill x ;
			::hwtk::label $frame1.l1 -text "temp file:"
			::hwtk::savefileentry $frame1.e1 -textvariable [namespace current]::m_file -help "temp file name" -title "select temp file"
			grid $frame1.l1 $frame1.e1 -sticky w -pady 2 -padx 5
			grid configure $frame1.e1 -sticky ew
			
			grid columnconfigure $frame1 1  -weight 1
			
		# Create the frame2
		set frame2 [labelframe $m_recess.frame2 -text "Command" ];
        pack $frame2 -side top -anchor nw -fill x ;
			::hwtk::button $frame2.change_name -text "change name" -help "change name" -command { ::hm::MyTab::change_name } 
			::hwtk::button $frame2.output_ansys -text "output ansys" -help "output ansys" -command { ::hm::MyTab::output_ansys } 
			::hwtk::button $frame2.input_lsdyna -text "input lsdyna" -help "input lsdyna" -command { ::hm::MyTab::input_lsdyna } 
			grid $frame2.change_name 
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
proc ::hm::MyTab::change_name { args } {
	##
	set state [ hm_commandfilestate 0]
	hm_blockmessages 1
	##
	
	
	
	##
	hm_commandfilestate $state
	hm_blockmessages 0
	##
}

#################################################################
proc ::hm::MyTab::output_ansys { args } {
	##
	set state [ hm_commandfilestate 0]
	hm_blockmessages 1
	##
	
	
	
	##
	hm_commandfilestate $state
	hm_blockmessages 0
	##
}

#################################################################
proc ::hm::MyTab::input_lsdyna { args } {
	##
	set state [ hm_commandfilestate 0]
	hm_blockmessages 1
	##
	
	
	
	##
	hm_commandfilestate $state
	hm_blockmessages 0
	##
}

#################################################################
if [ catch {::hm::MyTab::Main} err] {
	::hm::MyTab::Error $err
}
