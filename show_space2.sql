@inc/input_vars_init;
set serverout on;

declare
      /************************/
      procedure p( p_str in varchar2)
      is 
      begin 
          dbms_output.put_line( p_str);
      end;
      /************************/
      procedure p( p_label in varchar2, p_num in number )
      is 
      begin 
          dbms_output.put_line( rpad(p_label,40,'.') || 
                                to_char(p_num,'999,999,999,999') ); 
      end; 
      /** Main function: */
      procedure show_space( 
          p_segname   in varchar2, 
          p_owner     in varchar2 default user, 
          p_type      in varchar2 default 'TABLE', 
          p_partition in varchar2 default NULL
       )
      is 
          l_segname                   varchar2(30);
          l_owner                     varchar2(30);
          l_type                      varchar2(30);
          l_partition                 varchar2(30);
          ----------
          l_free_blks                 number; 
          l_total_blocks              number; 
          l_total_bytes               number; 
          l_unused_blocks             number; 
          l_unused_bytes              number; 
          l_LastUsedExtFileId         number; 
          l_LastUsedExtBlockId        number; 
          l_LAST_USED_BLOCK           number; 
          l_segment_space_mgmt        varchar2(255); 
          l_unformatted_blocks number; 
          l_unformatted_bytes number; 
          l_fs1_blocks number; l_fs1_bytes number; 
          l_fs2_blocks number; l_fs2_bytes number; 
          l_fs3_blocks number; l_fs3_bytes number; 
          l_fs4_blocks number; l_fs4_bytes number; 
          l_full_blocks number; l_full_bytes number; 
      begin 
         begin 
            execute immediate 
                'select ts.segment_space_management,seg.segment_name,seg.owner,seg.segment_type,seg.partition_name
                   from dba_segments seg, dba_tablespaces ts
                  where seg.tablespace_name = ts.tablespace_name
                    and seg.segment_name    like :p_segname
                    and sys_op_map_nonnull(seg.partition_name)  = sys_op_map_nonnull(:p_partition)
                    and seg.owner           like :p_owner
                    '
                   into l_segment_space_mgmt,l_segname,l_owner,l_type,l_partition
                    using upper(p_segname), upper(p_partition), upper(p_owner);
--                    and seg.tablespace_name = ts.tablespace_name
--                    and seg.segment_name    like p_segname
--                    and sys_op_map_nonnull(seg.partition_name)  = sys_op_map_nonnull(p_partition)
--                    and seg.owner           like p_owner
         exception
             when too_many_rows then
                dbms_output.put_line( 'Это секционированная таблица, используйте p_partition => ');
                return; 
         end; 
       
         p('-----------------------------------------------');
         p('*** Free blocks:');
         -- Если объект расположен в табличном пространстве ASSM, мы должны использовать 
         -- этот вызов для получения информации о пространстве, иначе мы используем 
         -- вызов FREE_BLOCKS для сегментов, управляемых пользователем 
         if l_segment_space_mgmt = 'AUTO' 
         then 
            dbms_space.space_usage(
                l_owner, l_segname, l_type
              , l_unformatted_blocks
               ,l_unformatted_bytes
               ,l_fs1_blocks , l_fs1_bytes 
               ,l_fs2_blocks , l_fs2_bytes 
               ,l_fs3_blocks , l_fs3_bytes
               ,l_fs4_blocks , l_fs4_bytes
               ,l_full_blocks, l_full_bytes
               ,p_partition
            );
       
            p( 'Unformatted Blocks ', l_unformatted_blocks ); 
            p( 'FS1 Blocks (0-25)  ', l_fs1_blocks ); 
            p( 'FS2 Blocks (25-50) ', l_fs2_blocks ); 
            p( 'FS3 Blocks (50-75) ', l_fs3_blocks ); 
            p( 'FS4 Blocks (75-100)', l_fs4_blocks ); 
            p( 'Full Blocks        ', l_full_blocks ); 
        else 
            dbms_space.free_blocks( 
               segment_owner     => l_owner
              ,segment_name      => l_segname
              ,segment_type      => l_type
              ,freelist_group_id => 0
              ,free_blks         => l_free_blks
            );
       
            p( 'Free Blocks', l_free_blks ); 
        end if; 
        -- Unused space:
        p('-----------------------------------------------');
        p('***  Unused space:');
        dbms_space.unused_space( 
           segment_owner     => l_owner, 
           segment_name      => l_segname, 
           segment_type      => l_type, 
           partition_name    => l_partition, 
           total_blocks      => l_total_blocks, 
           total_bytes       => l_total_bytes, 
           unused_blocks     => l_unused_blocks, 
           unused_bytes      => l_unused_bytes, 
           LAST_USED_EXTENT_FILE_ID => l_LastUsedExtFileId, 
           LAST_USED_EXTENT_BLOCK_ID => l_LastUsedExtBlockId, 
           LAST_USED_BLOCK => l_LAST_USED_BLOCK );
       
           p( 'Total Blocks'         , l_total_blocks                 ); 
           p( 'Total Bytes'          , l_total_bytes                  ); 
           p( 'Total MBytes'         , trunc(l_total_bytes/1024/1024) ); 
           p( 'Unused Blocks'        , l_unused_blocks                ); 
           p( 'Unused Bytes'         , l_unused_bytes                 ); 
           p( 'Last Used Ext FileId' , l_LastUsedExtFileId            ); 
           p( 'Last Used Ext BlockId', l_LastUsedExtBlockId           ); 
           p( 'Last Used Block'      , l_LAST_USED_BLOCK              ); 
   end; 
begin
   show_space( p_segname   => '&1'
              ,p_owner     => nvl('&2', USER)
              ,p_type      => nvl('&3','TABLE')
              ,p_partition => '&4'
             );
end;
/
set serverout off;
@inc/input_vars_undef;
