set head off feedback off  serveroutput on 
spool tab.js 
begin 
dbms_output.put_line('document.write("<table>");'); 	
dbms_output.put_line('document.write("<tr>");');
dbms_output.put_line('document.write("<caption>Wait class over day</caption>");');
dbms_output.put_line('document.write("<thead>");');
dbms_output.put_line('document.write("<th>WaitClass/Hour</th>");');
for i in 0..23 loop 
dbms_output.put_line('document.write("<th>'||i||'</th>");');
end loop;
dbms_output.put_line('document.write("</tr>");');
dbms_output.put_line('document.write("</thead>");');
dbms_output.put_line('document.write("<tbody>");');
dbms_output.put_line('document.write("<tr>");');
for i in (select distinct (wait_class ) a from (
select wait_class,round(sum(TIME_WAITED_MICRO)/1000000) time from DBA_HIST_SYSTEM_EVENT m join DBA_HIST_SNAPSHOT s on m.snap_id=s.snap_id 
        where S.BEGIN_INTERVAL_TIME between sysdate-2 and sysdate and wait_class <>'Idle'
        group by wait_class
        order by 1)
		) loop
dbms_output.put_line('document.write("<tr>")');
dbms_output.put_line('document.write("<th>'||i.a||'</th>")');
dbms_output.put_line('document.write("</tr>")');
end loop ;
dbms_output.put_line('document.write("</tbody>");');
dbms_output.put_line('document.write("</table>");');
end;
/
spool off
spool dbtime_data.js 
declare a_max number;
   metric varchar2(100):='DB CPU';
begin
dbms_output.put_line('window.onload = function(){');
dbms_output.put_line('	var xx = h337.create({"element":document.getElementById("heatmapArea"), "radius":10, "visible":true});');
dbms_output.put_line('var obj =');
select max(value) into a_max
  from ( 
select wait_class,s.snap_id ,round(sum(TIME_WAITED_MICRO)/1000000) value from DBA_HIST_SYSTEM_EVENT m join DBA_HIST_SNAPSHOT s on m.snap_id=s.snap_id 
        where S.BEGIN_INTERVAL_TIME between trunc(sysdate)-1 and trunc(sysdate) and wait_class <>'Idle'
        group by wait_class,s.snap_id
        order by wait_class
        ) order by wait_class;
dbms_output.put_line('{max:'||a_max||', data: [');
for i  in ( select  '{y:'||35*(trunc(rownum/24))||
      ', x:'||35*(1+mod((snap_id-first_value(snap_id) over (order by snap_id)),24))||
      ', count:'|| value ||'},' aa
  from ( 
select wait_class,s.snap_id ,round(sum(TIME_WAITED_MICRO)/1000000) value from DBA_HIST_SYSTEM_EVENT m join DBA_HIST_SNAPSHOT s on m.snap_id=s.snap_id 
        where S.BEGIN_INTERVAL_TIME between trunc(sysdate)-1 and trunc(sysdate) and wait_class <>'Idle'
        group by wait_class,s.snap_id
        order by wait_class
        ) order by wait_class
		) loop
dbms_output.put_line(i.aa);
end loop;
dbms_output.put_line('{y:0, x:0, count:0}');
dbms_output.put_line(']};');
dbms_output.put_line('xx.store.setDataSet(obj);');		
dbms_output.put_line('}');		
end;
/

spool off
exit