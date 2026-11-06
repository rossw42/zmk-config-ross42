# Identify which Solanum half is running which firmware, from the USB descriptors.
# Central (left) firmware exposes a HID keyboard; peripheral (right) never does.
Get-PnpDevice -PresentOnly -Class USB | ? InstanceId -match 'VID_1D50&PID_615E\\' | % {
    $id = $_.InstanceId
    $kids = (Get-PnpDeviceProperty -InstanceId $id -KeyName DEVPKEY_Device_Children).Data
    $hasKbd = [bool](Get-PnpDevice -PresentOnly -Class Keyboard | ? InstanceId -match 'VID_1D50' | ? {
        $p = (Get-PnpDeviceProperty -InstanceId $_.InstanceId -KeyName DEVPKEY_Device_Parent).Data
        (Get-PnpDeviceProperty -InstanceId $p -KeyName DEVPKEY_Device_Parent).Data -eq $id })
    $ports = Get-PnpDevice -PresentOnly -Class Ports | ? {
        (Get-PnpDeviceProperty -InstanceId $_.InstanceId -KeyName DEVPKEY_Device_Parent).Data -eq $id } | % FriendlyName
    $loc = (Get-PnpDeviceProperty -InstanceId $id -KeyName DEVPKEY_Device_LocationInfo).Data
    [pscustomobject]@{
        Serial   = ($id -split '\\')[-1]
        USBPort  = $loc
        COM      = ($ports -join ',')
        Keyboard = $hasKbd
        Firmware = $(if ($hasKbd) { 'CENTRAL (solanum_left)' } else { 'PERIPHERAL (solanum_right)' })
    }
} | Format-Table -AutoSize
