
local M1 ={}




function string:split( inSplitPattern, outResults )
    if not outResults then
        outResults = { }
    end
    local theStart = 1
    local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
    while theSplitStart do
        table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
        theStart = theSplitEnd + 1
        theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
    end
    table.insert( outResults, string.sub( self, theStart ) )
    return outResults
end


function lsblk_data(excluded_devices )
    local mounted_devices     = {}
    local not_mounted_devices = {}
    local m = 1
    local n = 1

    f=assert(io.popen("lsblk -lo NAME,FSTYPE,SIZE,TYPE,MOUNTPOINT"),'r')

    local s = assert(f:read('*a'))
    local myTable = s:split("\n")
    for i = 2, #myTable-1 do
        for j = 1, #excluded_devices do
            if string.find(myTable[i],excluded_devices[j]) then
                goto continue
            end 
        end
        if string.find(myTable[i], "disk") then
            goto continue
        end
        local newTable = {}
        local l = 1
        for value in string.gmatch(myTable[i], "/?%w+%p?/?%w+") do
            newTable[l] = value
            l = l + 1
        end
        if #newTable == 5 then 
            mounted_devices[m] = newTable
            m = m + 1
        else
            not_mounted_devices[n] = newTable
            n = n + 1
        end
        ::continue::
    end

    f:close()
    return mounted_devices, not_mounted_devices
    
end

function M1.menu_builder()
    mounted_usb_menu = {}
    not_mounted_usb_menu = {}
    mounted_devices, not_mounted_devices = lsblk_data({"sda"})
    for i=1, #mounted_devices do
        mounted_usb_menu[i] = {}
        for j=1, #mounted_devices[i] do
            mounted_usb_menu[i][j] = mounted_devices[i][j]
        end
    end
    for i=1, #not_mounted_devices do
        not_mounted_usb_menu[i] = {}
        for j=1, #not_mounted_devices[i] do
            not_mounted_usb_menu[i][j] = not_mounted_devices[i][j]
        end
    end
    return mounted_usb_menu, not_mounted_usb_menu 
end    

return M1
