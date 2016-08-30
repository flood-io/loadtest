vcl 4.0;

backend default {
  .host = "0.0.0.0:80";
}

sub vcl_deliver {
  if (obj.hits > 0) {
    set resp.http.X-Cache = "HIT";
    set resp.http.X-Count = obj.hits;
  } else {
    set resp.http.X-Cache = "MISS";
  }
  return (deliver);
}
