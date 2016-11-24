# redmine_zquery
Redmine plugin that allows using simple OR between query filters


## Licence and History
The files in this repository were imported from a Redmine plugin made by Quan VN _(without its permission, because I've not managed to contact him)_.

Link to the original source code distributed in a ZIP file : http://www.redmine.org/plugins/boolean_query

The name of the plugin was : _zquery_, then _\_query_ (to be loaded first), then _boolean query_ (as on the plugin page in redmine.org).


## Installation
Get the sources and put them into a directory named _query in the Redmine plugins directory :

	git clone https://github.com/mbideau/redmine_zquery.git plugins/_query


## Documentation
This plugin allows a simple use of OR operator in query.

This plugin adds three new filters, acting as markers: All follow (OR), Any follow (AND), Any follow (OR)
Here is how it works

1. All the filters to be ANDed (if any) should come first. They will be joined with AND as usual. Lets call it A part, A can be empty
2. Then comes one of the Marker filters: All follow (OR), Any follow (AND), Any follow (OR), lets call it M
3. Then come other filters for example f1, f2, f3

The result will be 

	A. If M is: All follow (OR) is Yes =>  (A) OR (f1 AND f2 AND f3)
				All follow (OR) is not Yes =>  (A) OR NOT (f1 AND f2 AND f3)
	B. If M is: Any follow (AND) is Yes => (A) AND (f1 OR f2 OR f3)
				Any follow (AND) is not Yes => (A) AND NOT (f1 OR f2 OR f3)
	C. If M is: Any follow (OR) is Yes =>  (A) OR (f1 OR f2 OR f3)
				Any follow (OR) is not Yes =>  (A) OR NOT (f1 OR f2 OR f3)

Notes:

1. It is possible to user more than one Marker in the query. What the term "follow" means is all the filters below till another marker or end.
2. This plugin is tested in Redmine 2.6.5, ruby 2, rails 3.2.2. By examining the code of statement method, I guest that it will work for 2.6.x, 3.0.3 (they all have the same statement method)

3. To help debug, I log the result of the statement method (with prefix STATEMENT) into log file at info level . You can exam this log to see if it works correctly

4. Here is the list of plugins that work with this plugin (in redmine 2.6.5, ruby 2, rails 3.2.2)

	a_common_libs
	advanced_membership_management
	due_date_reminder
	global_roles
	planner
	progressive_projects_list
	projects_treeview
	quick_edit
	quick_view
	recurring_tasks
	redmine__select2
	redmine_admin_monitor
	redmine_all_files
	redmine_app_notifications
	redmine_assets_plugin
	redmine_autowatch
	redmine_banner
	redmine_base_deface
	redmine_base_select2
	redmine_better_gantt_chart
	redmine_checklists
	redmine_custom_css
	redmine_custom_js
	redmine_custom_reports
	redmine_custom_workflows
	redmine_dashboard
	redmine_default_custom_query
	redmine_didyoumean
	redmine_digest
	redmine_dmsf
	redmine_drafts
	redmine_extended_spent_time
	redmine_graphs
	redmine_housekeeping
	redmine_impersonate_system
	redmine_importer
	redmine_improved_searchbox
	redmine_information
	redmine_issue_journal
	redmine_issues_sorting
	redmine_keyboard_shortcuts
	redmine_leaves
	redmine_lightbox2
	redmine_login_audit
	redmine_logs
	redmine_mail_reminder
	redmine_maintenance_mode
	redmine_mentions
	redmine_multiple_files_upload
	redmine_multiprojects_issue
	redmine_my_page_queries
	redmine_my_roadmaps
	redmine_pastebin
	redmine_people
	redmine_pipeline_plugin
	redmine_pivot
	redmine_planning
	redmine_questions
	redmine_redshares
	redmine_related_buster
	redmine_reorder_links_arbitrary
	redmine_role_replacements
	redmine_schedules
	redmine_silencer
	redmine_startpage
	redmine_stats
	redmine_status_history
	redmine_stealth
	redmine_subtasks_inherited_fields
	redmine_summed_fields
	redmine_tagging
	redmine_task_board
	redmine_theme_changer
	redmine_time_tracker
	redmine_timesheet_plugin
	redmine_track_control
	redmine_tweaks
	redmine_update_reminder
	redmine_user_issues
	redmine_watcher_groups
	redmine_workload
	rmplus_devtools
	sidebar_hide
	simple_author_change
	status_button
	stuff_to_do_plugin
	subscription

