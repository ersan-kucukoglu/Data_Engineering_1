
#HW4
select o.orderNumber, od.priceEach, od.quantityOrdered, p.productName, p.productLine, c.city, c.country, o.orderDate
from customers c
join orders o
on c.customerNumber=o.customerNumber
join orderdetails od
on o.orderNumber=od.orderNumber
join products p
on od.productCode=p.productCode;



