import os, xmlrpc.client, csv
U,D,L,P="http://localhost:8069","tienda","gerente",os.environ["ODOO_PASSWORD"]
uid=xmlrpc.client.ServerProxy(f"{U}/xmlrpc/2/common").authenticate(D,L,P,{})
o=xmlrpc.client.ServerProxy(f"{U}/xmlrpc/2/object")
x=lambda m,f,*a,**k:o.execute_kw(D,uid,P,m,f,list(a),k)
carta=[r["producto"] for r in csv.DictReader(open("carta.csv",encoding="utf-8-sig"),delimiter=";")]
cats=x("pos.category","search_read",[],fields=["name"],order="sequence,id")
print(f"Carta del TPV en Odoo (base {D}, usuario {L}), por categoría del punto de venta:\n")
tot=0
for c in cats:
    ps=x("product.template","search_read",[["available_in_pos","=",True],["pos_categ_ids","in",[c["id"]]]],fields=["name","list_price","taxes_id"],order="name")
    if not ps: continue
    print(f"{c['name']} ({len(ps)})")
    for p in ps:
        m="  " if p["name"] in carta else "  [no está en carta.csv] "
        print(f"{m}  {p['name']}: {p['list_price']:.2f} €"); tot+=1
print(f"\n{tot} productos en el TPV; los {len(carta)} de carta.csv aparecen {sum(1 for n in carta if x('product.template','search_count',[['name','=',n],['available_in_pos','=',True]]))} veces (sin duplicados: {all(x('product.template','search_count',[['name','=',n]])==1 for n in carta)}).")
