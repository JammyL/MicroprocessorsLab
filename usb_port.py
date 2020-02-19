import usb.core
import sys

# find our device
dev = usb.core.find(idVendor = 0x058f, idProduct = 0x6387)  #idVendor=0xfffe, idProduct=0x0002)

# was it found?
if dev is None:
    raise ValueError('Device not found')


for cfg in dev:
    sys.stdout.write(str(cfg.bConfigurationValue) + '\n')


# set the active configuration. With no arguments, the first
# configuration will be the active one
dev.set_configuration(1)

# get an endpoint instance
cfg = dev.get_active_configuration()
intf = cfg[(0,0)]

ep = usb.util.find_descriptor(
    intf,
    # match the first OUT endpoint
    custom_match = \
    lambda e: \
        usb.util.endpoint_direction(e.bEndpointAddress) == \
        usb.util.ENDPOINT_OUT)

assert ep is not None

#write the data
ep.write('test')
