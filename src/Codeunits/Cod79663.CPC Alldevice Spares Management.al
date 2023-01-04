codeunit 79663 "CPC Alldevice Spares Mngmt."
{
    trigger OnRun()
    begin
        AlldeviceAPISetup.Get();

        if AddOrModifyItem then begin
            AddOrModifyItemToAlldevice();
            exit;
        end;

        CheckIfProductExsistsInBC();

        if NewItemAdd then
            AddNewItemToBC()
        else
            ModifyExistingItemInBC();

        ClearAll();
    end;

    var
        AlldeviceAPILogs: Record "CPC Alldevice API Logs";
        AlldeviceAPISetup: Record "CPC Alldevice API Setup";
        Item: Record Item;
        AlldeviceAPIManagement: Codeunit "CPC Alldevice API Management";
        AddOrModifyItem: Boolean;
        NewItemAdd: Boolean;
        ItemNo: Code[20];
        SparePartJsonObject: JsonObject;

    procedure SetAddOrModifyItemParam(AddOrModify: Boolean; ItemToAlldevice: Record Item)
    begin
        AddOrModifyItem := AddOrModify;
        Item := ItemToAlldevice;
    end;

    procedure SetParameters(JsonObj: JsonObject)
    begin
        SparePartJsonObject := JsonObj;
    end;

    local procedure AddNewItemToBC()
    var
        Item: Record Item;
        ItemCategory: Record "Item Category";
        ItemTempl: Record "Item Templ.";
        ItemTemplMgt: Codeunit "Item Templ. Mgt.";
    begin
        Item.Init();
        Item.Validate("No.", AlldeviceAPIManagement.GetJsonToken(SparePartJsonObject, 'code').AsValue().AsCode());
        Item.Insert(true);

        if ItemTempl.Get(AlldeviceAPISetup."CPC Spare Part Item Template") then
            ItemTemplMgt.ApplyItemTemplate(Item, ItemTempl);

        Item."CPC Alldevice Product Id" := AlldeviceAPIManagement.GetJsonToken(SparePartJsonObject, 'product_id').AsValue().AsInteger();
        Item.GTIN := AlldeviceAPIManagement.GetJsonToken(SparePartJsonObject, 'ean').AsValue().AsCode();
        Item.Validate(Description, AlldeviceAPIManagement.GetJsonToken(SparePartJsonObject, 'name').AsValue().AsText());
        Item.Validate("Unit Price", AlldeviceAPIManagement.GetJsonToken(SparePartJsonObject, 'price').AsValue().AsDecimal());
        if ItemCategory.Get(AlldeviceAPIManagement.GetJsonToken(SparePartJsonObject, 'cat_name').AsValue().AsCode()) then
            Item.Validate("Item Category Code", ItemCategory.Code);
        Item.Modify(true);
    end;

    local procedure AddOrModifyItemToAlldevice()
    var
        ItemCategory: Record "Item Category";
        Manufacturer: Record Manufacturer;
        Response: HttpResponseMessage;
        NewOrModifiedSpareJsonObject: JsonObject;
        RequestJson: JsonObject;
        ResponseJson: JsonObject;
    begin
        RequestJson := AlldeviceAPIManagement.GetRequestJsonWithAuth();

        RequestJson.Add('name', Item.Description);
        RequestJson.Add('code', Item."No.");
        RequestJson.Add('product_id', Item."CPC Alldevice Product Id");

        if ItemCategory.Get(Item."Item Category Code") then
            if ItemCategory."CPC Alldevice Category Id" <> 0 then
                RequestJson.Add('cat_id', ItemCategory."CPC Alldevice Category Id");

        if Manufacturer.Get(Item."Manufacturer Code") then
            if Manufacturer."CPC Alldevice Manufacturer Id" <> 0 then
                RequestJson.Add('manufacturer_id', Manufacturer."CPC Alldevice Manufacturer Id");

        ResponseJson := AlldeviceAPIManagement.PostRequest(AlldeviceAPISetup."CPC Update or Add Spare Prefix", RequestJson);

        if AlldeviceAPIManagement.GetJsonToken(ResponseJson, 'success').AsValue().AsBoolean() = true then begin
            NewOrModifiedSpareJsonObject := AlldeviceAPIManagement.GetJsonToken(ResponseJson, 'response').AsObject();
            Item."CPC Alldevice Product Id" := AlldeviceAPIManagement.GetJsonToken(NewOrModifiedSpareJsonObject, 'product_id').AsValue().AsInteger();
            Item."CPC Last Synced To Alldevice" := CurrentDateTime();
            Item.Modify(true);

            AlldeviceAPILogs.CreateApiLog(RequestJson, ResponseJson, AlldeviceAPISetup."CPC Update or Add Spare Prefix", true, '', '');
        end else begin
            AlldeviceAPILogs.CreateApiLog(RequestJson,
                                            ResponseJson,
                                            AlldeviceAPISetup."CPC Update or Add Spare Prefix",
                                            false,
                                            '',
                                            AlldeviceAPIManagement.GetJsonToken(ResponseJson, 'message').AsValue().AsText());
        end;
    end;

    local procedure CheckIfProductExsistsInBC()
    var
        Item: Record Item;
    begin
        if Item.Get(AlldeviceAPIManagement.GetJsonToken(SparePartJsonObject, 'code').AsValue().AsCode()) then begin
            // If product already exists, update it if needed.
            NewItemAdd := false;
            ItemNo := Item."No.";
        end else begin
            // Add new product.
            NewItemAdd := true;
        end;
    end;

    local procedure ModifyExistingItemInBC()
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);

        if Item."CPC Alldevice Product Id" <> AlldeviceAPIManagement.GetJsonToken(SparePartJsonObject, 'product_id').AsValue().AsInteger() then
            Item."CPC Alldevice Product Id" := AlldeviceAPIManagement.GetJsonToken(SparePartJsonObject, 'product_id').AsValue().AsInteger();

        if Item."CPC Alldevice Spare" <> true then
            Item."CPC Alldevice Spare" := true;

        if Item.GTIN <> AlldeviceAPIManagement.GetJsonToken(SparePartJsonObject, 'ean').AsValue().AsCode() then
            Item.GTIN := AlldeviceAPIManagement.GetJsonToken(SparePartJsonObject, 'ean').AsValue().AsCode();

        if Item.Description <> AlldeviceAPIManagement.GetJsonToken(SparePartJsonObject, 'name').AsValue().AsText() then
            Item.Validate(Description, AlldeviceAPIManagement.GetJsonToken(SparePartJsonObject, 'name').AsValue().AsText());

        if Item."Unit Price" <> AlldeviceAPIManagement.GetJsonToken(SparePartJsonObject, 'price').AsValue().AsDecimal() then
            Item.Validate("Unit Price", AlldeviceAPIManagement.GetJsonToken(SparePartJsonObject, 'price').AsValue().AsDecimal());

        if Item."Item Category Code" <> AlldeviceAPIManagement.GetJsonToken(SparePartJsonObject, 'cat_name').AsValue().AsCode() then
            Item.Validate("Item Category Code", AlldeviceAPIManagement.GetJsonToken(SparePartJsonObject, 'cat_name').AsValue().AsCode());

        Item.Modify(true);
    end;
}