codeunit 79666 "CPC Alldevice Categories"
{
    trigger OnRun()
    begin
        AlldeviceAPISetup.Get();

        SyncCategoriesFromAlldeviceToBC();
        SyncCategoriesFromBCToAlldevice();

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
        Errors: Record "Error Message" temporary;
        AlldeviceAPIManagement: Codeunit "CPC Alldevice API Management";
        AlldeviceCategoriesMngmt: Codeunit "CPC Alldevice Cat. Mngmt.";
        AlldeviceAPILogs: Record "CPC Alldevice API Logs";
        Error: ErrorInfo;
        EmptyJson: JsonObject;
        AlldeviceStockError: Label 'Error from Alldevice Categories %1';
        AddedItemCatToBcLbl: Label 'Item Category %1 synced to BC';
        ProgressMsg: Label 'Processing Categories......#1######################\';

    local procedure AddError(var StockJsonObject: JsonObject; var Errors: Record "Error Message" temporary)
    begin
        Errors.ID := Errors.ID + 1;
        Errors.Description := GetLastErrorText();
        Errors."Additional Information" := StrSubstNo(AlldeviceStockError, AlldeviceAPIManagement.GetJsonToken(StockJsonObject, 'name').AsValue().AsCode());
        Errors.Insert();
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure SyncCategoriesFromAlldeviceToBC()
    var
        ProgressDialog: Dialog;
        i: Integer;
        CategoriesJsonObject: JsonObject;
        ResponseJson: JsonObject;
        CategoriesJsonToken: JsonToken;
        Data: JsonToken;
    begin
        ResponseJson.ReadFrom(AlldeviceAPIManagement.GetList(AlldeviceAPISetup."CPC Get Categories List Prefix"));
        ResponseJson.SelectToken('$.response', Data);
        ProgressDialog.Open(ProgressMsg);

        for i := 0 to Data.AsArray.Count() - 1 do begin
            Data.AsArray().Get(i, CategoriesJsonToken);
            CategoriesJsonObject := CategoriesJsonToken.AsObject();
            AlldeviceCategoriesMngmt.SetParameters(CategoriesJsonObject);
            Commit();

            if not AlldeviceCategoriesMngmt.Run() then
                AddError(CategoriesJsonObject, Errors)
            else
                AlldeviceAPILogs.CreateApiLog(CategoriesJsonObject,
                                            EmptyJson,
                                            AlldeviceAPISetup."CPC Get Categories List Prefix",
                                            true,
                                            '',
                                            StrSubstNo(AddedItemCatToBcLbl, AlldeviceAPIManagement.GetJsonToken(CategoriesJsonObject, 'name').AsValue().AsCode()));


            ProgressDialog.Update(1, i);
            if GuiAllowed then
                Sleep(10);
        end;
        ProgressDialog.Close();
    end;

    local procedure SyncCategoriesFromBCToAlldevice()
    var
        ItemCat: Record "Item Category";
        ProgressDialog: Dialog;
        i: Integer;
    begin
        ItemCat.Reset();
        ItemCat.SetRange("Parent Category", AlldeviceAPISetup."CPC Main Category");

        i := 0;
        ProgressDialog.Open(ProgressMsg);

        if ItemCat.FindSet() then begin
            repeat
                if ItemCat.SystemModifiedAt > ItemCat."CPC Last Synced To Alldevice" then begin
                    Clear(AlldeviceCategoriesMngmt);
                    AlldeviceCategoriesMngmt.SetAddOrModifyItemCatParam(true, ItemCat);
                    AlldeviceCategoriesMngmt.Run();
                end;
                ProgressDialog.Update(1, i);
                if GuiAllowed then
                    Sleep(10);
                i += 1;
            until ItemCat.Next() = 0;
        end;
        ProgressDialog.Close();
    end;
}