codeunit 79662 "CPC Alldevice Spares"
{
    trigger OnRun()
    begin
        AlldeviceAPISetup.Get();

        SyncSparePartsFromAlldeviceToBC();
        SyncSparePartsFromBCToAlldevice();

        if HasCollectedErrors then
            foreach Error in System.GetCollectedErrors() do begin
                Errors.ID := Errors.ID + 1;
                Errors.Description := Error.Message;
                Errors.Insert();
            end;

        ClearCollectedErrors();

        if GuiAllowed then begin
            Commit();
            Page.RunModal(Page::"Error Messages", Errors);
        end;
    end;

    var
        AlldeviceAPILogs: Record "CPC Alldevice API Logs";
        AlldeviceAPISetup: Record "CPC Alldevice API Setup";
        Errors: Record "Error Message" temporary;
        AlldeviceAPIManagement: Codeunit "CPC Alldevice API Management";
        AlldeviceSparesMngmt: Codeunit "CPC Alldevice Spares Mngmt.";
        NewItemAdd: Boolean;
        Error: ErrorInfo;
        EmptyJson: JsonObject;
        AddedItemToBcLbl: Label 'Item %1 synced to BC';
        AlldeviceItemError: Label 'Error from Alldevice Item %1';
        ProgressMsg: Label 'Processing Items......#1######################\';

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure SyncSparePartsFromAlldeviceToBC()
    var
        ProgressDialog: Dialog;
        i: Integer;
        ResponseJson: JsonObject;
        SparePartJsonObject: JsonObject;
        Data: JsonToken;
        SparePartJsonToken: JsonToken;
    begin
        ResponseJson.ReadFrom(AlldeviceAPIManagement.GetList(AlldeviceAPISetup."CPC Get Spares List Prefix"));
        ResponseJson.SelectToken('$.response.data', Data);
        ProgressDialog.Open(ProgressMsg);

        for i := 0 to Data.AsArray.Count() - 1 do begin
            Data.AsArray().Get(i, SparePartJsonToken);
            SparePartJsonObject := SparePartJsonToken.AsObject();
            AlldeviceSparesMngmt.SetParameters(SparePartJsonObject);
            Commit();

            if not AlldeviceSparesMngmt.Run() then
                AddError(SparePartJsonObject, Errors)
            else begin
                AlldeviceAPILogs.CreateApiLog(SparePartJsonObject,
                                            EmptyJson,
                                            AlldeviceAPISetup."CPC Get Spares List Prefix",
                                            true,
                                            '',
                                            StrSubstNo(AddedItemToBcLbl, 
                                            AlldeviceAPIManagement.GetJsonToken(SparePartJsonObject, 'code').AsValue().AsCode()));
            end;

            ProgressDialog.Update(1, i);

            if GuiAllowed then
                Sleep(10);
        end;
        ProgressDialog.Close();
    end;

    local procedure SyncSparePartsFromBCToAlldevice()
    var
        Item: Record Item;
        ProgressDialog: Dialog;
        i: Integer;
    begin
        Item.SetRange("CPC Alldevice Spare", true);
        i := 0;
        ProgressDialog.Open(ProgressMsg);

        if Item.FindSet() then begin
            repeat
                if Item.SystemModifiedAt > Item."CPC Last Synced To Alldevice" then begin
                    Clear(AlldeviceSparesMngmt);
                    AlldeviceSparesMngmt.SetAddOrModifyItemParam(true, Item);
                    AlldeviceSparesMngmt.Run();
                end;
                ProgressDialog.Update(1, i);
                if GuiAllowed then
                    Sleep(10);
                i += 1;
            until Item.Next() = 0;
        end;
        ProgressDialog.Close();
    end;

    local procedure AddError(var SparePartJsonObject: JsonObject; var Errors: Record "Error Message" temporary)
    begin
        Errors.ID := Errors.ID + 1;
        Errors.Description := GetLastErrorText();
        Errors."Additional Information" := StrSubstNo(AlldeviceItemError, AlldeviceAPIManagement.GetJsonToken(SparePartJsonObject, 'code').AsValue().AsCode());
        Errors.Insert();
        AlldeviceAPILogs.CreateApiLog(SparePartJsonObject, EmptyJson, AlldeviceAPISetup."CPC Get Spares List Prefix", false, Errors.Description, Errors."Additional Information");
    end;
}