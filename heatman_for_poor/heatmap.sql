set head off feedback off  serveroutput on 
spool tab.js 
begin 
dbms_output.put_line('document.write("<table>");');
dbms_output.put_line('document.write("<tr>");');
dbms_output.put_line('document.write("<caption>DB CPU over week</caption>");');
dbms_output.put_line('document.write("<thead>");');
dbms_output.put_line('document.write("<th>Day/Hour</th>");');
for i in 0..23 loop 
dbms_output.put_line('document.write("<th>'||i||'</th>");');
end loop;
dbms_output.put_line('document.write("</tr>");');
dbms_output.put_line('document.write("</thead>");');
dbms_output.put_line('document.write("<tbody>");');
dbms_output.put_line('document.write("<tr>");');
for i in (select  distinct( to_char( trunc(s.BEGIN_INTERVAL_TIME),'dd/mm/yyyy') ) a from DBA_HIST_SNAPSHOT  s order by to_char( trunc(s.BEGIN_INTERVAL_TIME),'dd/mm/yyyy')) loop
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
select max(a) into a_max from (select  ( nvl(round((value-lag(value) over (order by s.snap_id))/1000000),0))  a from DBA_HIST_SYS_TIME_MODEL m join DBA_HIST_SNAPSHOT s on m.snap_id=s.snap_id 
            where stat_name=metric) ;
dbms_output.put_line('{max:'||a_max||', data: [');
for i  in ( select  '{y:'||35*(1+trunc((s.snap_id-first_value(s.snap_id) over (order by s.snap_id))/24))||', x:'||35*(1+mod((s.snap_id-first_value(s.snap_id) over (order by s.snap_id)),24))||', count:'|| nvl(round((value-lag(value) over (order by s.snap_id))/1000000),0)||'},' aa  from DBA_HIST_SYS_TIME_MODEL m join DBA_HIST_SNAPSHOT s on m.snap_id=s.snap_id 
            where stat_name=metric ) loop
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