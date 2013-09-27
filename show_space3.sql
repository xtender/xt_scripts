declare 
   /** formatting */
   len_owner                   int:=20;           
   len_segment_name            int:=30;
   len_partition_name          int:=30;
   len_segment_type            int:=10;
   len_free_blocks             int:=15;
   len_total_blocks            int:=15;
   len_unused_blocks           int:=15;
   len_last_used_ext_fileid    int:=10;
   len_last_used_ext_blockid   int:=10;
   len_last_used_block         int:=10;
   /** */
   procedure p( p_label in varchar2, p_num in number ) is
   begin
      dbms_output.put_line( rpad(p_label,40,'.') || p_num );
   end;
   /** */
   procedure p_header is
   begin
      dbms_output.put_line(  rpad('owner           ',len_owner                ,' ') ||' | '
                         ||  rpad('segment_name    ',len_segment_name         ,' ') ||' | '     
                         ||  rpad('partition_name  ',len_partition_name       ,' ') ||' | '
                         ||  rpad('segment_type    ',len_segment_type         ,' ') ||' | '
                         ||  rpad('free_blocks     ',len_free_blocks          ,' ') ||' | '
                         ||  rpad('total_blocks    ',len_total_blocks         ,' ') ||' | '
                         ||  rpad('unused_blocks   ',len_unused_blocks        ,' ') ||' | '
                         ||  rpad('l.ext_fileid    ',len_last_used_ext_fileid ,' ') ||' | '
                         ||  rpad('l.ext_blockid   ',len_last_used_ext_blockid,' ') ||' | '
                         ||  rpad('l.block         ',len_last_used_block      ,' ') ||' | '
                        );
      dbms_output.put_line(rpad('-',300,'-'));
   end;
   /** */
   procedure p_data(p_owner                 varchar2,
                    p_segment_name          varchar2,
                    p_partition_name        varchar2,
                    p_segment_type          varchar2,
                    p_free_blocks           number, 
                    p_total_blocks          number, 
                    p_unused_blocks         number, 
                    p_last_used_ext_fileid  number, 
                    p_last_used_ext_blockid number, 
                    p_last_used_block       number 
                   )
   is
   begin
      dbms_output.put_line(  rpad(p_owner                ,len_owner                ,' ') ||' | '
                         ||  rpad(p_segment_name         ,len_segment_name         ,' ') ||' | '     
                         ||  rpad(p_partition_name       ,len_partition_name       ,' ') ||' | '
                         ||  rpad(p_segment_type         ,len_segment_type         ,' ') ||' | '
                         ||  rpad(p_free_blocks          ,len_free_blocks          ,' ') ||' | '
                         ||  rpad(p_total_blocks         ,len_total_blocks         ,' ') ||' | '
                         ||  rpad(p_unused_blocks        ,len_unused_blocks        ,' ') ||' | '
                         ||  rpad(p_last_used_ext_fileid ,len_last_used_ext_fileid ,' ') ||' | '
                         ||  rpad(p_last_used_ext_blockid,len_last_used_ext_blockid,' ') ||' | '
                         ||  rpad(p_last_used_block      ,len_last_used_block      ,' ') ||' | '
                        );
   end;
   
   /** main function */
   procedure show_space_for (p_segname   in varchar2, 
                             p_owner     in varchar2 default user, 
                             p_type      in varchar2 default 'TABLE', 
                             p_partition in varchar2 default NULL ) 
   as 
       cursor l_cursor is 
                 select seg.owner
                      , seg.segment_name
                      , seg.segment_type
                      , seg.partition_name
                      , ts.segment_space_management
                   from dba_segments     seg
                       ,dba_tablespaces  ts
                 where seg.tablespace_name = ts.tablespace_name
                 and   seg.owner           like upper(p_owner)
                 and   seg.segment_name    like upper(p_segname)
                 and   seg.segment_type    like upper(p_type);
       
       
       l_free_blks                 number; 
       l_total_blocks              number; 
       l_total_bytes               number; 
       l_unused_blocks             number; 
       l_unused_bytes              number; 
       l_LastUsedExtFileId         number; 
       l_LastUsedExtBlockId        number; 
       l_last_used_block           number; 
       l_sql                       long; 
       l_conj                      varchar2(7) default ' where '; 
       l_owner                     varchar2(30); 
       l_segment_name              varchar2(30); 
       l_segment_type              varchar2(30); 
       l_partition_name            varchar2(30); 
       l_segment_space_management  varchar2(30);
       
       l_unformatted_blocks        number;
       l_unformatted_bytes         number;
       l_fs1_blocks  number; l_fs1_bytes  number;
       l_fs2_blocks  number; l_fs2_bytes  number;
       l_fs3_blocks  number; l_fs3_bytes  number;
       l_fs4_blocks  number; l_fs4_bytes  number;
       l_full_blocks number; l_full_bytes number;

   begin 
       execute immediate 'alter session set cursor_sharing=force'; 
       open l_cursor; 
       execute immediate 'alter session set cursor_sharing=exact'; 
       
       loop 
           fetch l_cursor into l_owner, l_segment_name, l_segment_type, l_partition_name, l_segment_space_management; 

           exit when l_cursor%notfound; 
           begin 
              if l_segment_space_management='AUTO' then
                 begin
                    dbms_space.space_usage (
                      l_owner,
                      l_segment_name,
                      l_segment_type,
                      l_unformatted_blocks,
                      l_unformatted_bytes,
                      l_fs1_blocks, l_fs1_bytes,
                      l_fs2_blocks, l_fs2_bytes,
                      l_fs3_blocks, l_fs3_bytes,
                      l_fs4_blocks, l_fs4_bytes,
                      l_full_blocks, l_full_bytes
                    );
                    --
                    dbms_output.put_line( 'Segment :'|| l_segment_type||' '||l_owner||'.'||l_segment_name);
                    p( 'Unformatted Blocks ', l_unformatted_blocks );
                    p( 'FS1 Blocks (0-25)  ', l_fs1_blocks );
                    p( 'FS2 Blocks (25-50) ', l_fs2_blocks );
                    p( 'FS3 Blocks (50-75) ', l_fs3_blocks );
                    p( 'FS4 Blocks (75-100)', l_fs4_blocks );
                    p( 'Full Blocks        ', l_full_blocks );
                 end;
              else
                 begin
                    dbms_space.free_blocks 
                       ( segment_owner     => l_owner, 
                         segment_name      => l_segment_name, 
                         segment_type      => l_segment_type, 
                         partition_name    => l_partition_name, 
                         freelist_group_id => 0, 
                         free_blks         => l_free_blks 
                       ); 
                    dbms_space.unused_space 
                       ( segment_owner     => l_owner, 
                         segment_name      => l_segment_name, 
                         segment_type      => l_segment_type, 
                         partition_name    => l_partition_name, 
                         total_blocks      => l_total_blocks, 
                         total_bytes       => l_total_bytes, 
                         unused_blocks     => l_unused_blocks, 
                         unused_bytes      => l_unused_bytes, 
                         LAST_USED_EXTENT_FILE_ID => l_LastUsedExtFileId, 
                         LAST_USED_EXTENT_BLOCK_ID => l_LastUsedExtBlockId, 
                         LAST_USED_BLOCK   => l_LAST_USED_BLOCK 
                       ); 
                     p_header;
                     p_data(  l_owner, l_segment_name, l_partition_name, 
                              l_segment_type, l_free_blks, l_total_blocks, l_unused_blocks, 
                              l_lastUsedExtFileId, l_LastUsedExtBlockId, l_last_used_block ); 
                  end;
               end if;
           exception 
               when others then dbms_output.put_line(sqlerrm);
           end; 
       end loop; 
       close l_cursor; 
 
   end; 
/************************************************************************/   
/**  main block: */
begin
   show_space_for( 
                 p_segname   =>'&tab_name'
                ,p_owner     =>'&owner'
                ,p_type      =>'%' 
                ,p_partition => null
                );
end;
/
