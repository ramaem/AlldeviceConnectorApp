codeunit 79669 "CPC Alldevice Tasks"
{
    local procedure GetListSpares(Prefix: Text; TaskId: Integer) ResponseText: Text
    var
        AlldeviceAPIManagement: Codeunit "CPC Alldevice API Management";
        RequestJson: JsonObject;
        RequestJsonText: Text;
        Client: HttpClient;
        Response: HttpResponseMessage;
        Body: Text;
        Content: HttpContent;
        RequestURL: Text;
    begin
        RequestJson := AlldeviceAPIManagement.GetRequestJsonWithAuth();
        RequestJson.Add('task_id', TaskId);
        RequestJson.WriteTo(RequestJsonText);
        Content.WriteFrom(RequestJsonText);
        RequestURL := AlldeviceAPISetup."CPC Alldevice API URL" + Prefix;
        Client.Post(RequestURL, Content, Response);
        Response.Content.ReadAs(ResponseText);
    end;

    procedure GetTasksRecord(var AlldeviceServiceTasks: Record "CPC Alldevice Service Tasks" temporary)
    var
        ResponseJson: JsonObject;
        TaskJsonObject: JsonObject;
        TaskJsonToken: JsonToken;
        i: Integer;
        Data: JsonToken;
        ProgressDialog: Dialog;
    begin
        AlldeviceAPISetup.Get();
        ResponseJson.ReadFrom(AlldeviceAPIManagement.GetList(AlldeviceAPISetup."CPC Get Service Task List"));
        ResponseJson.SelectToken('$.response.data', Data);
        ProgressDialog.Open(ProgressMsg);

        for i := 0 to Data.AsArray.Count() - 1 do begin
            Data.AsArray().Get(i, TaskJsonToken);
            TaskJsonObject := TaskJsonToken.AsObject();

            AlldeviceServiceTasks.Init();
            AlldeviceServiceTasks."CPC Task Id" := AlldeviceAPIManagement.GetJsonToken(TaskJsonObject, 'task_id').AsValue().AsInteger();
            if AlldeviceAPIManagement.GetJsonToken(TaskJsonObject, 'device_name').AsValue().IsNull() then
                AlldeviceServiceTasks."CPC Device Name" := ''
            else
                AlldeviceServiceTasks."CPC Device Name" := AlldeviceAPIManagement.GetJsonToken(TaskJsonObject, 'device_name').AsValue().AsText();
            AlldeviceServiceTasks."CPC Service Name" := AlldeviceAPIManagement.GetJsonToken(TaskJsonObject, 'service_name').AsValue().AsText();
            if AlldeviceAPIManagement.GetJsonToken(TaskJsonObject, 'service_description').AsValue().IsNull() then
                AlldeviceServiceTasks."CPC Service Description" := ''
            else
                AlldeviceServiceTasks."CPC Service Description" := AlldeviceAPIManagement.GetJsonToken(TaskJsonObject, 'service_description').AsValue().AsText();
            AlldeviceServiceTasks."CPC Task Status" := AlldeviceAPIManagement.GetJsonToken(TaskJsonObject, 'task_status').AsValue().AsText();
            if AlldeviceAPIManagement.GetJsonToken(TaskJsonObject, 'device_status').AsValue().IsNull() then
                AlldeviceServiceTasks."CPC Device Status" := ''
            else
                AlldeviceServiceTasks."CPC Device Status" := AlldeviceAPIManagement.GetJsonToken(TaskJsonObject, 'device_status').AsValue().AsText();
            AlldeviceServiceTasks."CPC Is Completed" := AlldeviceAPIManagement.GetJsonToken(TaskJsonObject, 'is_completed').AsValue().AsBoolean();
            AlldeviceServiceTasks."CPC Completed Date" := AlldeviceAPIManagement.GetJsonToken(TaskJsonObject, 'completed_date').AsValue().AsDate();
            AlldeviceServiceTasks.Insert();

            ProgressDialog.Update(1, i);
        end;
    end;

    procedure GetUsedSparesList(var ServiceTaskLines: Record "CPC Alld. Service Task Lines"; TaskId: Integer)
    var
        ResponseJson: JsonObject;
        Data: JsonToken;
        i: Integer;
        SpareJsonObject: JsonObject;
        SpareJsonToken: JsonToken;
    begin
        ServiceTaskLines.DeleteAll();
        AlldeviceAPISetup.Get();
        ResponseJson.ReadFrom(GetListSpares(AlldeviceAPISetup."CPC Get Used Spares List Pref.", TaskId));
        ResponseJson.SelectToken('$.response', Data);

        for i := 0 to Data.AsArray.Count() - 1 do begin
            Data.AsArray().Get(i, SpareJsonToken);
            SpareJsonObject := SpareJsonToken.AsObject();

            if not AlldeviceAPIManagement.GetJsonToken(SpareJsonObject, 'product_id').AsValue().IsNull() then begin
                ServiceTaskLines.Init();
                ServiceTaskLines."CPC Id" := AlldeviceAPIManagement.GetJsonToken(SpareJsonObject, 'id').AsValue().AsInteger();
                ServiceTaskLines."CPC Code" := AlldeviceAPIManagement.GetJsonToken(SpareJsonObject, 'code').AsValue().AsCode();
                ServiceTaskLines."CPC Quantity" := AlldeviceAPIManagement.GetJsonToken(SpareJsonObject, 'quantity').AsValue().AsDecimal();
                ServiceTaskLines."CPC Alldevice Task Id" := TaskId;
                ServiceTaskLines.Insert();
            end;
        end;
    end;

    var
        AlldeviceAPISetup: Record "CPC Alldevice API Setup";
        ProgressMsg: Label 'Processing Service Tasks from Alldevice......#1######################\';
        AlldeviceAPIManagement: Codeunit "CPC Alldevice API Management";
}