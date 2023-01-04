codeunit 79668 "CPC Alldevice Manuf. Mngmt."
{
    trigger OnRun()
    begin
        AlldeviceAPISetup.Get();

        if AddOrModifyManufacturer then begin
            AddOrModifyManufacturerToAlldevice();
            exit;
        end;

        CheckIfCategoryExsists();

        if NewManufacturerAdd then
            AddNewManufacturerToBC()
        else
            ModifyExistingManufacturerInBc();

        ClearAll();
    end;

    var
        AlldeviceAPISetup: Record "CPC Alldevice API Setup";
        Manufacturer: Record Manufacturer;
        AlldeviceAPIManagement: Codeunit "CPC Alldevice API Management";
        NewManufacturerAdd: Boolean;
        ManufacturerCode: Code[10];
        ManufacturerJsonObject: JsonObject;
        AddOrModifyManufacturer: Boolean;
        AlldeviceAPILogs: Record "CPC Alldevice API Logs";

    local procedure AddOrModifyManufacturerToAlldevice()
    var
        RequestJson: JsonObject;
        ResponseJson: JsonObject;
        NewOrModifiedManufacturerObject: JsonObject;
    begin
        RequestJson := AlldeviceAPIManagement.GetRequestJsonWithAuth();

        RequestJson.Add('name', Manufacturer.Code);
        RequestJson.Add('id', Manufacturer."CPC Alldevice Manufacturer Id");

        ResponseJson := AlldeviceAPIManagement.PostRequest(AlldeviceAPISetup."CPC Update or add manuf. Pref.", RequestJson);

        if AlldeviceAPIManagement.GetJsonToken(ResponseJson, 'success').AsValue().AsBoolean() = true then begin
            NewOrModifiedManufacturerObject := AlldeviceAPIManagement.GetJsonToken(ResponseJson, 'response').AsObject();
            Manufacturer."CPC Alldevice Manufacturer Id" := AlldeviceAPIManagement.GetJsonToken(NewOrModifiedManufacturerObject, 'id').AsValue().AsInteger();
            Manufacturer."CPC Last Synced To Alldevice" := CurrentDateTime();
            Manufacturer.Modify(true);

            AlldeviceAPILogs.CreateApiLog(RequestJson, ResponseJson, AlldeviceAPISetup."CPC Update or add manuf. Pref.", true, '', '');
        end else begin
            AlldeviceAPILogs.CreateApiLog(RequestJson,
                                            ResponseJson,
                                            AlldeviceAPISetup."CPC Update or add manuf. Pref.",
                                            false,
                                            '',
                                            AlldeviceAPIManagement.GetJsonToken(ResponseJson, 'message').AsValue().AsText());
        end;
    end;

    procedure SetAddOrModifyManufacturerParam(AddOrModify: Boolean; ManufacturerToAlldevice: Record Manufacturer)
    begin
        AddOrModifyManufacturer := AddOrModify;
        Manufacturer := ManufacturerToAlldevice;
    end;

    procedure SetParameters(JsonObj: JsonObject)
    begin
        ManufacturerJsonObject := JsonObj;
    end;

    local procedure AddNewManufacturerToBC()
    var
        Manufacturer: Record Manufacturer;
    begin
        Manufacturer.Init();
        Manufacturer.Code := AlldeviceAPIManagement.GetJsonToken(ManufacturerJsonObject, 'name').AsValue().AsCode();
        Manufacturer.Name := AlldeviceAPIManagement.GetJsonToken(ManufacturerJsonObject, 'name').AsValue().AsCode();
        Manufacturer.Insert();
    end;

    local procedure CheckIfCategoryExsists()
    var
        Manufacturer: Record Manufacturer;
    begin
        if Manufacturer.Get(AlldeviceAPIManagement.GetJsonToken(ManufacturerJsonObject, 'name').AsValue().AsCode()) then begin
            // If product already exists, update it if needed.
            NewManufacturerAdd := false;
            ManufacturerCode := Manufacturer.Code;
        end else begin
            // Add new product.
            NewManufacturerAdd := true;
        end;
    end;

    local procedure ModifyExistingManufacturerInBc()
    var
        Manufacturer: Record Manufacturer;
    begin
        Manufacturer.Get(ManufacturerCode);

        if Manufacturer."CPC Alldevice Manufacturer Id" <> AlldeviceAPIManagement.GetJsonToken(ManufacturerJsonObject, 'id').AsValue().AsInteger() then
            Manufacturer."CPC Alldevice Manufacturer Id" := AlldeviceAPIManagement.GetJsonToken(ManufacturerJsonObject, 'id').AsValue().AsInteger();

        Manufacturer.Modify();
    end;
}