codeunit 79661 "CPC Alldevice Manufacturer"
{
    trigger OnRun()
    begin
        AlldeviceAPISetup.Get();

        SyncManufacturersFromAlldeviceToBC();
        SyncManufacturersFromBCToAlldevice();


        if HasCollectedErrors then
            foreach Error in system.GetCollectedErrors() do begin
                errors.ID := errors.ID + 1;
                errors.Description := Error.Message;
                errors.Insert();
            end;

        ClearCollectedErrors();

        if GuiAllowed then begin
            Commit();
            Page.RunModal(Page::"Error Messages", errors);
        end;
    end;

    var
        AlldeviceAPISetup: Record "CPC Alldevice API Setup";
        AlldeviceAPIManagement: Codeunit "CPC Alldevice API Management";
        AlldeviceManufacturerMngmt: Codeunit "CPC Alldevice Manuf. Mngmt.";
        Error: ErrorInfo;
        Errors: Record "Error Message" temporary;
        AlldeviceAPILogs: Record "CPC Alldevice API Logs";
        EmptyJson: JsonObject;
        AlldeviceManufError: Label 'Error from Alldevice Manufacturers %1';
        AddedItemManufToBcLbl: Label 'Item Manufacturer %1 synced to BC';
        ProgressMsg: Label 'Processing Manufacturers......#1######################\';

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure SyncManufacturersFromAlldeviceToBC()
    var
        ProgressDialog: Dialog;
        i: Integer;
        ManufacturerJsonObject: JsonObject;
        ResponseJson: JsonObject;
        Data: JsonToken;
        ManufacturerJsonToken: JsonToken;
    begin
        ResponseJson.ReadFrom(AlldeviceAPIManagement.GetList(AlldeviceAPISetup."CPC Get Manuf. List Prefix"));
        ResponseJson.SelectToken('$.response', Data);
        ProgressDialog.Open(ProgressMsg);

        for i := 0 to Data.AsArray.Count() - 1 do begin
            Data.AsArray().Get(i, ManufacturerJsonToken);
            ManufacturerJsonObject := ManufacturerJsonToken.AsObject();
            AlldeviceManufacturerMngmt.SetParameters(ManufacturerJsonObject);
            Commit();

            if not AlldeviceManufacturerMngmt.Run() then
                AddError(ManufacturerJsonObject, Errors)
            else
                AlldeviceAPILogs.CreateApiLog(ManufacturerJsonObject,
                            EmptyJson,
                            AlldeviceAPISetup."CPC Get Categories List Prefix",
                            true,
                            '',
                            StrSubstNo(AddedItemManufToBcLbl, AlldeviceAPIManagement.GetJsonToken(ManufacturerJsonObject, 'name').AsValue().AsCode()));

            ProgressDialog.Update(1, i);
            if GuiAllowed then
                Sleep(10);
        end;
        ProgressDialog.Close();
    end;

    local procedure SyncManufacturersFromBCToAlldevice()
    var
        Manufacturer: Record Manufacturer;
        ProgressDialog: Dialog;
        i: Integer;
    begin
        Manufacturer.Reset();

        i := 0;
        ProgressDialog.Open(ProgressMsg);

        if Manufacturer.FindSet() then
            repeat
                if Manufacturer.SystemModifiedAt > Manufacturer."CPC Last Synced To Alldevice" then begin
                    Clear(AlldeviceManufacturerMngmt);
                    AlldeviceManufacturerMngmt.SetAddOrModifyManufacturerParam(true, Manufacturer);
                    AlldeviceManufacturerMngmt.Run();
                end;
                ProgressDialog.Update(1, i);
                if GuiAllowed then
                    Sleep(10);
                i += 1;
            until Manufacturer.Next() = 0;
        ProgressDialog.Close();
    end;

    local procedure AddError(var ManufacturerJsonObject: JsonObject; var Errors: Record "Error Message" temporary)
    begin
        Errors.ID := Errors.ID + 1;
        Errors.Description := GetLastErrorText();
        Errors."Additional Information" := StrSubstNo(AlldeviceManufError, AlldeviceAPIManagement.GetJsonToken(ManufacturerJsonObject, 'name').AsValue().AsCode());
        Errors.Insert();
    end;
}