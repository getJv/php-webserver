<?php 
    $a = 2;
    $b = $a + 2;
?>
<a href="/">PHP INFO</a> | 
<a href="/?xdebug">XDEBUG INFO</a>

<?php   
    
    if(isset($_GET['xdebug'])) 
        xdebug_info() ;
    else 
        phpinfo(); 
?>
