# Target : reports.solarflare.hv

# Ports & services Enumerations

```js
    ~/Téléchargements/Openvpn ❯ nmap -sV -sC -T4 reports.solarflare.hv -p-                                                                                                        08:06:47
Starting Nmap 7.99 ( https://nmap.org ) at 2026-06-29 08:06 +0000
Stats: 0:06:29 elapsed; 0 hosts completed (1 up), 1 undergoing SYN Stealth Scan
SYN Stealth Scan Timing: About 51.60% done; ETC: 08:19 (0:06:04 remaining)
Stats: 0:12:58 elapsed; 0 hosts completed (1 up), 1 undergoing SYN Stealth Scan
SYN Stealth Scan Timing: About 99.38% done; ETC: 08:19 (0:00:05 remaining)
Nmap scan report for reports.solarflare.hv (172.20.1.94)
Host is up (0.16s latency).
Not shown: 65532 closed tcp ports (reset)
PORT      STATE SERVICE   VERSION
80/tcp    open  http      Apache httpd 2.4.56 ((Debian))
|_http-server-header: Apache/2.4.56 (Debian)
|_http-title: Login
3306/tcp  open  mysql     MariaDB 5.5.5-10.5.21
| mysql-info: 
|   Protocol: 10
|   Version: 5.5.5-10.5.21-MariaDB-0+deb11u1
|   Thread ID: 54
|   Capabilities flags: 63486
|   Some Capabilities: IgnoreSigpipes, InteractiveClient, SupportsTransactions, DontAllowDatabaseTableColumn, Speaks41ProtocolOld, Speaks41ProtocolNew, IgnoreSpaceBeforeParenthesis, LongColumnFlag, ConnectWithDatabase, Support41Auth, ODBCClient, SupportsLoadDataLocal, FoundRows, SupportsCompression, SupportsMultipleResults, SupportsAuthPlugins, SupportsMultipleStatments
|   Status: Autocommit
|   Salt: &{[7?vU&]%>G,CN<%@Te
|_  Auth Plugin Name: mysql_native_password
11211/tcp open  memcached Memcached 1.6.9 (uptime 2132 seconds)

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 804.82 seconds
```

# memcached Enumeration

```js
    ~/Téléchargements/Openvpn ❯ telnet reports.solarflare.hv 11211                                                                                                         12s   08:26:26
Trying 172.20.1.94...
Connected to reports.solarflare.hv.
Escape character is '^]'.

ERROR

ERROR
HELP
ERROR
stats
STAT pid 395
STAT uptime 2789
STAT time 1782721863
STAT version 1.6.9
STAT libevent 2.1.12-stable
STAT pointer_size 64
STAT rusage_user 0.676995
STAT rusage_system 0.519183
STAT max_connections 1024
STAT curr_connections 1
STAT total_connections 5
STAT rejected_connections 0
STAT connection_structures 2
STAT response_obj_oom 0
STAT response_obj_count 1
STAT response_obj_bytes 49152
STAT read_buf_count 7
STAT read_buf_bytes 114688
STAT read_buf_bytes_free 49152
STAT read_buf_oom 0
STAT reserved_fds 20
STAT cmd_get 0
STAT cmd_set 1
STAT cmd_flush 0
STAT cmd_touch 0
STAT cmd_meta 0
STAT get_hits 0
STAT get_misses 0
STAT get_expired 0
STAT get_flushed 0
STAT delete_misses 0
STAT delete_hits 0
STAT incr_misses 0
STAT incr_hits 0
STAT decr_misses 0
STAT decr_hits 0
STAT cas_misses 0
STAT cas_hits 0
STAT cas_badval 0
STAT touch_hits 0
STAT touch_misses 0
STAT auth_cmds 0
STAT auth_errors 0
STAT bytes_read 161
STAT bytes_written 2174
STAT limit_maxbytes 67108864
STAT accepting_conns 1
STAT listen_disabled_num 0
STAT time_in_listen_disabled_us 0
STAT threads 4
STAT conn_yields 0
STAT hash_power_level 16
STAT hash_bytes 524288
STAT hash_is_expanding 0
STAT slab_reassign_rescues 0
STAT slab_reassign_chunk_rescues 0
STAT slab_reassign_evictions_nomem 0
STAT slab_reassign_inline_reclaim 0
STAT slab_reassign_busy_items 0
STAT slab_reassign_busy_deletes 0
STAT slab_reassign_running 0
STAT slabs_moved 0
STAT lru_crawler_running 0
STAT lru_crawler_starts 10
STAT lru_maintainer_juggles 5653
STAT malloc_fails 0
STAT log_worker_dropped 0
STAT log_worker_written 0
STAT log_watcher_skipped 0
STAT log_watcher_sent 0
STAT unexpected_napi_ids 0
STAT round_robin_fallback 0
STAT bytes 175
STAT curr_items 1
STAT total_items 1
STAT slab_global_page_pool 0
STAT expired_unfetched 0
STAT evicted_unfetched 0
STAT evicted_active 0
STAT evictions 0
STAT reclaimed 0
STAT crawler_reclaimed 0
STAT crawler_items_checked 9
STAT lrutail_reflocked 0
STAT moves_to_cold 1
STAT moves_to_warm 0
STAT moves_within_lru 0
STAT direct_reclaims 0
STAT lru_bumps_dropped 0
END
stats cachedump 1 100
END

ERROR
stats items
STAT items:4:number 1
STAT items:4:number_hot 0
STAT items:4:number_warm 0
STAT items:4:number_cold 1
STAT items:4:age_hot 0
STAT items:4:age_warm 0
STAT items:4:age 2824
STAT items:4:mem_requested 175
STAT items:4:evicted 0
STAT items:4:evicted_nonzero 0
STAT items:4:evicted_time 0
STAT items:4:outofmemory 0
STAT items:4:tailrepairs 0
STAT items:4:reclaimed 0
STAT items:4:expired_unfetched 0
STAT items:4:evicted_unfetched 0
STAT items:4:evicted_active 0
STAT items:4:crawler_reclaimed 0
STAT items:4:crawler_items_checked 9
STAT items:4:lrutail_reflocked 0
STAT items:4:moves_to_cold 1
STAT items:4:moves_to_warm 0
STAT items:4:moves_within_lru 0
STAT items:4:direct_reclaims 0
STAT items:4:hits_to_hot 0
STAT items:4:hits_to_warm 0
STAT items:4:hits_to_cold 0
STAT items:4:hits_to_temp 0
END
get key_name
END

ERROR
stats cachedump <X> 100
CLIENT_ERROR bad command line format
stats cachedump 1 100
END
stats cachedump 4 100
ITEM session_key:a4ea55d5e8e7d9871b0f47e8641024a86ed11f63d06ca7793d5af122110b [44 b; 0 s]
END
get session_key:a4ea55d5e8e7d9871b0f47e8641024a86ed11f63d06ca7793d5af122110b

VALUE session_key:a4ea55d5e8e7d9871b0f47e8641024a86ed11f63d06ca7793d5af122110b 0 44
user_id:dc1cfc1e-cbc7-46d1-b88d-f8dd0ab163f7
END
ERROR

```

## session_key : a4ea55d5e8e7d9871b0f47e8641024a86ed11f63d06ca7793d5af122110b
## User_ID : dc1cfc1e-cbc7-46d1-b88d-f8dd0ab163f7

# Web Enumeration find

```js
http://reports.solarflare.hv/dashboard.php
http://reports.solarflare.hv/logs.php
```

