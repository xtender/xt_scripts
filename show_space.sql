prompt *** Script based on show_space procedure by T.Kyte
prompt &_c_reverse. Usage: @show_space [seg_mask [owner_mask [type [part_mask]] &_C_RESET.
@inc/input_vars_init;
var c refcursor;
def _strlen=60
col "#" format 9999
col text format a&_strlen
declare
      lines sys.ku$_errorlines:=sys.ku$_errorlines();
      n int:=0;
      
      strlen constant int:=&_strlen;
      /************************/
      procedure p( p_str in varchar2)
      is 
      begin 
          IF FALSE THEN
             dbms_output.put_line( p_str);
          ELSE
             lines.extend();
             n:=n+1;
             lines(n):=sys.ku$_errorline( n, p_str );
          END IF;
      end p;
      /************************/
      procedure p( p_label in varchar2, p_num in number )
      is 
         str varchar2(2000):=rpad(p_label,strlen-16,'.') 
                               || to_char(p_num,'999,999,999,999');
      begin 
         
          IF FALSE THEN
             dbms_output.put_line( str ); 
          ELSE
             lines.extend();
             n:=n+1;
             lines(n):=sys.ku$_errorline( n ,str );
          END IF;
      end p; 
      /************************/
      procedure print_free_blocks(
         p_segment_space_management in varchar2
        ,lp_owner                   in varchar2
        ,lp_segment                 in varchar2
        ,lp_type                    in varchar2
        ,lp_partition               in varchar2
      )
      is
         l_unformatted_blocks number; 
         l_unformatted_bytes number; 
         l_fs1_blocks number; l_fs1_bytes number; 
         l_fs2_blocks number; l_fs2_bytes number; 
         l_fs3_blocks number; l_fs3_bytes number; 
         l_fs4_blocks number; l_fs4_bytes number; 
         l_full_blocks number; l_full_bytes number; 
         l_free_blks                 number; 
      begin
         p('* Free blocks:');
         if p_segment_space_management = 'AUTO' 
         then 
            dbms_space.space_usage(
                lp_owner, lp_segment, lp_type
              , l_unformatted_blocks
               ,l_unformatted_bytes
               ,l_fs1_blocks , l_fs1_bytes 
               ,l_fs2_blocks , l_fs2_bytes 
               ,l_fs3_blocks , l_fs3_bytes
               ,l_fs4_blocks , l_fs4_bytes
               ,l_full_blocks, l_full_bytes
               ,lp_partition
            );
            p( 'Unformatted Blocks ', l_unformatted_blocks ); 
            p( 'FS1 Blocks (0-25)  ', l_fs1_blocks ); 
            p( 'FS2 Blocks (25-50) ', l_fs2_blocks ); 
            p( 'FS3 Blocks (50-75) ', l_fs3_blocks ); 
            p( 'FS4 Blocks (75-100)', l_fs4_blocks ); 
            p( 'Full Blocks        ', l_full_blocks ); 
         else 
            dbms_space.free_blocks( 
               segment_owner     => lp_owner
              ,segment_name      => lp_segment
              ,segment_type      => lp_type
              ,freelist_group_id => 0
              ,free_blks         => l_free_blks
            );
            p( 'Free Blocks', l_free_blks ); 
         end if; 
      end print_free_blocks;
      /********************************************/
      procedure print_unused_blocks(
         lp_owner                   in varchar2
        ,lp_segment                 in varchar2
        ,lp_type                    in varchar2
        ,lp_partition               in varchar2
      )
      is
          l_total_blocks              number; 
          l_total_bytes               number; 
          l_unused_blocks             number; 
          l_unused_bytes              number; 
          l_LastUsedExtFileId         number; 
          l_LastUsedExtBlockId        number; 
          l_LAST_USED_BLOCK           number; 
      begin
         -- Unused space:
         --p('-----------------------------------------------');
         p('*  Unused space:');
         dbms_space.unused_space( 
            segment_owner     => lp_owner,
            segment_name      => lp_segment,
            segment_type      => lp_type,
            partition_name    => lp_partition,
            total_blocks      => l_total_blocks,
            total_bytes       => l_total_bytes,
            unused_blocks     => l_unused_blocks,
            unused_bytes      => l_unused_bytes,
            LAST_USED_EXTENT_FILE_ID  => l_LastUsedExtFileId,
            LAST_USED_EXTENT_BLOCK_ID => l_LastUsedExtBlockId, 
            LAST_USED_BLOCK           => l_LAST_USED_BLOCK 
         );
         p( 'Total Blocks'         , l_total_blocks                 );
         p( 'Total Bytes'          , l_total_bytes                  );
         p( 'Total MBytes'         , trunc(l_total_bytes/1024/1024) );
         p( 'Unused Blocks'        , l_unused_blocks                );
         p( 'Unused Bytes'         , l_unused_bytes                 );
         p( 'Last Used Ext FileId' , l_LastUsedExtFileId            );
         p( 'Last Used Ext BlockId', l_LastUsedExtBlockId           );
         p( 'Last Used Block'      , l_LAST_USED_BLOCK              );
      end;
      /********************************************/
      /** Main function: */
      procedure show_space(
          p_segmask   in varchar2, 
          p_ownermask     in varchar2 default user, 
          p_type      in varchar2 default 'TABLE', 
          p_partition in varchar2 default NULL
       )
      is
      begin 
         for r in ( 
                     select ts.segment_space_management
                           ,seg.owner
                           ,seg.segment_name
                           ,seg.segment_type
                           ,seg.partition_name
                     from 
                          dba_segments seg
                          join dba_tablespaces ts
                               on seg.tablespace_name = ts.tablespace_name
                     where 
                          seg.segment_name    like p_segmask
                      and seg.owner           like p_ownermask
                      and seg.segment_type    like p_type
                      and (p_partition is null or seg.partition_name like p_partition)
                     order by 1,2,3,4,5
                   )
         loop
            p(rpad('***    '
                     || r.owner ||'.'|| r.segment_name
                     || case 
                           when r.partition_name is not null 
                              then '('||r.partition_name||')' 
                        end
                     || '  '
                  ,strlen
                  ,'*'
                  )
              );
            print_free_blocks(
                r.segment_space_management
               ,r.owner
               ,r.segment_name
               ,r.segment_type
               ,r.partition_name
            );
            print_unused_blocks(
                r.owner
               ,r.segment_name
               ,r.segment_type
               ,r.partition_name
            );
            p(rpad('#',strlen,'#'));
      end loop;
   end; 
begin
   show_space( p_segmask   => upper('&1')
              ,p_ownermask => upper(nvl('&2', '%'))
              ,p_type      => upper(nvl('&3','%'))
              ,p_partition => upper('&4')
             );
   open :c for 
      select 
        errorNumber as "#"
       ,errorText   as Text
      from table(lines) t
      order by 1;
end;
/
print c;
@inc/input_vars_undef;
