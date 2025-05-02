let
    Source = Folder.Files("Path"),
    #"Filtered Hidden Files1" = Table.SelectRows(Source, each [Attributes]?[Hidden]? <> true),
    #"Invoke Custom Function1" = Table.AddColumn(#"Filtered Hidden Files1", "Transform File", each #"Transform File"([Content])),
    #"Renamed Columns1" = Table.RenameColumns(#"Invoke Custom Function1", {"Name", "Source.Name"}),
    #"Removed Other Columns1" = Table.SelectColumns(#"Renamed Columns1", {"Source.Name", "Transform File"}),
    #"Expanded Table Column1" = Table.ExpandTableColumn(#"Removed Other Columns1", "Transform File", Table.ColumnNames(#"Transform File"(#"Sample File"))),
    #"Changed Type" = Table.TransformColumnTypes(#"Expanded Table Column1",{{"Source.Name", type text}, {"CallDate", type date}, {"CallTime", type datetime}, {"CustomerID", type text}, {"CustomerIDTxt", type text}, {"ProductType", type text}, {"AgentID", Int64.Type}, {"PrimaryCallType", type text}, {"SecondaryCallType", type text}, {"CallType", type text}, {"ConnectionID", Int64.Type}, {"Duration", Int64.Type}, {"LOB", type text}, {"SupervisorID", Int64.Type}, {"ManagerID", Int64.Type}, {"CallActivityLog", Int64.Type}, {"Email", type any}, {"Segment", type text}, {"First Name", type text}, {"CallMonth", type text}, {"CallYear", Int64.Type}}),
    #"Appended Query" = Table.Combine({#"Changed Type", #"Real time"}),
    #"Removed Columns1" = Table.RemoveColumns(#"Appended Query",{"RMN"}),
    #"Merged Queries" = Table.NestedJoin(#"Removed Columns1", {"AgentID"}, #"Agent wise", {"logid"}, "Agent wise", JoinKind.LeftOuter),
    #"Expanded Agent wise" = Table.ExpandTableColumn(#"Merged Queries", "Agent wise", {"logid", "Emp Name", "Team Leader", "Manager", "Affluent", "Location"}, {"Agent wise.logid", "Agent wise.Emp Name", "Agent wise.Team Leader", "Agent wise.Manager", "Agent wise.Affluent", "Agent wise.Location"}),
    #"Changed Type1" = Table.TransformColumnTypes(#"Expanded Agent wise",{{"CallActivityLog", type text}}),
    #"Merged Queries1" = Table.NestedJoin(#"Changed Type1", {"CallActivityLog"}, Response, {"CallActivityLog"}, "Response", JoinKind.LeftOuter),
    #"Expanded Response" = Table.ExpandTableColumn(#"Merged Queries1", "Response", {"Response Type", "Officer CSAT", "(Group) Q4_NPS_GROUP", "NPS", "Query Resolution", "FCR", "CallActivityLog"}, {"Response.Response Type", "Response.Officer CSAT", "Response.(Group) Q4_NPS_GROUP", "Response.NPS", "Response.Query Resolution", "Response.FCR", "Response.CallActivityLog"}),
    #"Removed Duplicates" = Table.Distinct(#"Expanded Response", {"CallActivityLog"}),
    #"Replaced Value" = Table.ReplaceValue(#"Removed Duplicates",null,"No Response",Replacer.ReplaceValue,{"Response.(Group) Q4_NPS_GROUP"}),
    #"Changed Type2" = Table.TransformColumnTypes(#"Replaced Value",{{"CallMonth", type text}}),
    #"Removed Columns" = Table.RemoveColumns(#"Changed Type2",{"Source.Name"}),
    #"Filtered Rows" = Table.SelectRows(#"Removed Columns", each ([CallMonth] <> "Mar")),
    #"Added Custom" = Table.AddColumn(#"Filtered Rows", "Survey trigger types", each if Text.Contains([CallType], "Survey POC") then "Real Time" else if List.MatchesAny(Text.ToList([CallMonth]), each Text.Select(_,{"0".."9"}) <> "") then "NRMN" else "RMN"),
    #"Filtered Rows1" = Table.SelectRows(#"Added Custom", each true),
    #"Replaced Value1" = Table.ReplaceValue(#"Filtered Rows1","(blank)","Personal",Replacer.ReplaceText,{"Segment"}),
    #"Replaced Value2" = Table.ReplaceValue(#"Replaced Value1","Premium Banking","Premium",Replacer.ReplaceText,{"Segment"}),
    #"Replaced Value3" = Table.ReplaceValue(#"Replaced Value2","Personal Banking","Personal",Replacer.ReplaceText,{"Segment"}),
    #"Replaced Value4" = Table.ReplaceValue(#"Replaced Value3","Priority Banking","Priority",Replacer.ReplaceText,{"Segment"}),
    #"Added Custom1" = Table.AddColumn(#"Replaced Value4", "Final FCR", each if [Response.Query Resolution] = "Yes" and [Response.FCR] = "Yes" then "Yes" else "No"),
    #"Changed Type3" = Table.TransformColumnTypes(#"Added Custom1",{{"Final FCR", type text}}),
    #"Replaced Value5" = Table.ReplaceValue(#"Changed Type3","Business Banking","Business",Replacer.ReplaceText,{"Segment"}),
    #"Filtered Rows2" = Table.SelectRows(#"Replaced Value5", each ([CallMonth] = "4" or [CallMonth] = "Apr")),
    
in
    #"Filtered Rows2"


--------------------------------------------------------
Whats the difference between above code and below... 

Make sure the logic is same.. in the below code.
--------------------------------------------------------

let
    Source = Folder.Files("C:\Users\8216609\OneDrive - Standard Chartered Bank\Desktop\PB_Survey\2025\Qual\Apr"),
    #"Filtered Hidden Files1" = Table.SelectRows(Source, each [Attributes]?[Hidden]? <> true),
    #"Transform Data" = Table.AddColumn(#"Filtered Hidden Files1", "Data", each #"Transform File"([Content])),
    #"Expanded Data" = Table.ExpandTableColumn(#"Transform Data", "Data", Table.ColumnNames(#"Transform File"(#"Sample File"))),
    #"Added Source Name" = Table.AddColumn(#"Expanded Data", "Source.Name", each [Name]),
    #"Changed Types" = Table.TransformColumnTypes(#"Added Source Name", {
        {"Source.Name", type text}, {"CallDate", type date}, {"CallTime", type datetime}, {"CustomerID", type text},
        {"CustomerIDTxt", type text}, {"ProductType", type text}, {"AgentID", Int64.Type}, {"PrimaryCallType", type text},
        {"SecondaryCallType", type text}, {"CallType", type text}, {"ConnectionID", Int64.Type}, {"Duration", Int64.Type},
        {"LOB", type text}, {"SupervisorID", Int64.Type}, {"ManagerID", Int64.Type}, {"CallActivityLog", Int64.Type},
        {"Email", type any}, {"Segment", type text}, {"First Name", type text}, {"CallMonth", type text}, {"CallYear", Int64.Type}
    }),
    #"Appended Query" = Table.Combine({#"Changed Types", #"RealTime"}),
    #"Removed column" = Table.RemoveColumns(#"Appended Query",{"RMN"}),

    // Convert AgentID to text before join
    #"AgentID to Text" = Table.TransformColumnTypes(#"Removed column",{{"AgentID", type text}}),

    // Use Table.Buffer if "Team List" is small and static
    BufferedTeamList = Table.Buffer(#"Team List"),
    #"Joined with Team List" = Table.NestedJoin(#"AgentID to Text", {"AgentID"}, BufferedTeamList, {"logid"}, "Team List", JoinKind.LeftOuter),
    #"Expanded Team List" = Table.ExpandTableColumn(#"Joined with Team List", "Team List", {"logid", "Emp Name", "Team Leader", "Manager", "Affluent", "Location"}),

    // Convert CallActivityLog to text before join
    #"CallActivityLog to Text" = Table.TransformColumnTypes(#"Expanded Team List",{{"CallActivityLog", type text}}),

    BufferedResponse = Table.Buffer(Response),
    #"Joined with Response" = Table.NestedJoin(#"CallActivityLog to Text", {"CallActivityLog"}, BufferedResponse, {"CallActivityLog"}, "Response", JoinKind.LeftOuter),
    #"Expanded Response" = Table.ExpandTableColumn(#"Joined with Response", "Response", {"Response Type", "Officer CSAT", "(Group) Q4_NPS_GROUP", "NPS", "Query Resolution", "FCR"}),

    #"Removed Duplicates" = Table.Distinct(#"Expanded Response", {"CallActivityLog"}),
    #"Replace Null with No Response" = Table.ReplaceValue(#"Removed Duplicates", null, "No Response", Replacer.ReplaceValue, {"(Group) Q4_NPS_GROUP"}),
    #"Filtered CallMonth" = Table.SelectRows(#"Replace Null with No Response", each [CallMonth] = "Apr" or [CallMonth] = "4"),

    // Add Survey trigger
    #"Add Survey Trigger" = Table.AddColumn(#"Filtered CallMonth", "Survey trigger types", each 
        if Text.Contains([CallType], "Survey POC") then "Real Time" 
        else if List.MatchesAny(Text.ToList([CallMonth]), each Text.Select(_, {"0".."9"}) <> "") then "NRMN" 
        else "RMN"),
    // Normalize Segment
    SegmentsToReplace = {
        {"(blank)", "Personal"},
        {"Premium Banking", "Premium"},
        {"Personal Banking", "Personal"},
        {"Priority Banking", "Priority"},
        {"Business Banking", "Business"}
    },
    #"Normalized Segment" = List.Accumulate(SegmentsToReplace, #"Add Survey Trigger", (state, current) => 
        Table.ReplaceValue(state, current{0}, current{1}, Replacer.ReplaceText, {"Segment"})
    ),
    // Add Final FCR
    #"Add Final FCR" = Table.AddColumn(#"Normalized Segment", "Final FCR", each if [Query Resolution] = "Yes" and [FCR] = "Yes" then "Yes" else "No", type text),
    // Filter valid dates only
    #"Filtered NonNull Dates" = Table.SelectRows(#"Add Final FCR", each ([CallDate] <> null)),
    // Add Week of Month info and cleanup
    #"Add Week Columns" = Table.AddColumn(#"Filtered NonNull Dates", "Weekly", each 
        let week = Date.WeekOfMonth([CallDate]) 
        in "Week " & Text.From(if week > 4 then 4 else week)
    ),
    #"Removed Unnecessary Columns" = Table.RemoveColumns(#"Add Week Columns",{"Source.Name", "Content", "Name", "Extension", "Date accessed", "Date modified", "Date created", "Attributes", "Folder Path"})
in
    #"Removed Unnecessary Columns"


