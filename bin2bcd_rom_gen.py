def bin2bcd_table():
    table = []
    for i in range(256):
        bcd_value = 0
        temp = i
        for _ in range(8):
            bcd_value <<= 4
            bcd_value |= temp % 10
            temp //= 10
        table.append(bcd_value)
    return table

lookup_table = bin2bcd_table()
hex_table=[]
for i in lookup_table:
    hex_table.append(hex(i))
print(hex_table)