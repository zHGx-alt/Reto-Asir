#!/bin/sh
# Pasa el stick (Arduino Leonardo, VID 2341) entre el PC y la VM de la recreativa.
#   ./pasar-stick.sh pc   -> el PC lo ve (para ver-mando.py y el puerto serie)
#   ./pasar-stick.sh vm   -> lo usa MAME en la VM
# Uso: VM=OtraVM ./pasar-stick.sh vm   (por defecto, Recreativa-Demo)
VM=${VM:-Recreativa-Demo}
UUID=$(VBoxManage list usbhost | awk '/^UUID:/{u=$2} /VendorId:.*0x2341/{print u; exit}')
[ -n "$UUID" ] || { echo "No veo el stick por USB: ¿está enchufado?"; exit 1; }

case "$1" in
  pc)
    VBoxManage usbfilter modify 0 --target "$VM" --active no
    VBoxManage controlvm "$VM" usbdetach "$UUID" 2>/dev/null
    sleep 2
    ls -l /dev/input/by-id/ | grep -i joystick && echo "Listo: el stick lo tiene el PC."
    ;;
  vm)
    # MAME solo busca mandos al arrancar: se reinicia la VM con el filtro activo
    # para que el stick ya esté conectado cuando se abra MAME.
    VBoxManage usbfilter modify 0 --target "$VM" --active yes
    if VBoxManage showvminfo "$VM" --machinereadable | grep -q 'VMState="running"'; then
      echo "Apagando la VM..."
      VBoxManage controlvm "$VM" acpipowerbutton
      until VBoxManage showvminfo "$VM" --machinereadable | grep -q 'VMState="poweroff"'; do sleep 1; done
      sleep 3
    fi
    until VBoxManage startvm "$VM" --type gui >/dev/null 2>&1; do sleep 1; done
    echo "Arrancando la VM con el stick: cronometra hasta que salga MAME."
    ;;
  *) echo "Uso: $0 pc|vm"; exit 1 ;;
esac
