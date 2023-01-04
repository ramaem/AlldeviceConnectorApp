permissionset 79660 AlldeviceApp
{
    Assignable = true;
    Permissions = tabledata "CPC Alld. Service Task Lines" = RIMD,
        tabledata "CPC Alldevice API Logs" = RIMD,
        tabledata "CPC Alldevice API Setup" = RIMD,
        tabledata "CPC Alldevice Service Tasks" = RIMD,
        table "CPC Alld. Service Task Lines" = X,
        table "CPC Alldevice API Logs" = X,
        table "CPC Alldevice API Setup" = X,
        table "CPC Alldevice Service Tasks" = X,
        report "CPC Alldevice Item Jour. Lines" = X,
        codeunit "CPC Alldevice API Management" = X,
        codeunit "CPC Alldevice Cat. Mngmt." = X,
        codeunit "CPC Alldevice Categories" = X,
        codeunit "CPC Alldevice Manuf. Mngmt." = X,
        codeunit "CPC Alldevice Manufacturer" = X,
        codeunit "CPC Alldevice Spares" = X,
        codeunit "CPC Alldevice Spares Mngmt." = X,
        codeunit "CPC Alldevice Tasks" = X,
        page "CPC Alldevice API Logs" = X,
        page "CPC Alldevice API Setup" = X,
        page "CPC Alldevice Tasks List" = X;
}