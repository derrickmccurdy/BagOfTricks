<?php
/* http://oreillynet.com/pub/a/php/2004/05/13/shared_memory.html?page=2
The URL above was the starting point for this code. The author is Alexander Prohorenko
and I would buy him a beverage or three of his choice if I ever met him. 
*/

//sysvshm
//sysvsem
//shmop

class SemaphoreException extends Exception
{
	function __construct()
	{
		parent::__construct()
		error_log(parent::getTraceAsString()) ;
	}
}


class DSemaphore
{

	/**
	*
	*/
	protected static function getNewKey()
	{
		$mtime = microtime() ;
		$mtime = substr(ereg_replace('^0\.([0-9]*)00 ([0-9]*)','\2\1',$mtime),5) ;
		return $mtime ;
	}


	/**
	* $key must be an integer greater than 100000
	*/
	protected static function createSemaphore($key = 100001)// Create a semaphore
	{
		try
		{
			if((!is_numeric($key)) || (100000 <= $key))
			{
				throw new Exception('Argument was empty\n'.serialize(debug_backtrace())) ;
			}

			$semaphore_id = sem_get($key, 1);
			if(! checkResource($semaphore_id, 'sysvsem'))//DERRICK need to find out ACTUAL type returned
			{
				throw new SemaphoreException('Failed to create semaphore:'.$key.'\n') ;
			}
			return $semaphore_id ;
		}
		catch(Exception $e)
		{
			throw $e ;
		}
	}

	/**
	* $semaphore_id must be a resource obtained from a previous call to createSemaphore
	*/
	protected static function acquireSemaphore($semaphore_id)// Acquire the semaphore
	{
		try
		{
			if(! checkResource($semaphore_id, "sysvsem"))//DERRICK need to find out ACTUAL type returned
			{
				throw new Exception('Semaphore id provided was not a resource or wrong type. '.serialize(debug_backtrace())) ;
			}
			if (! sem_acquire($semaphore_id))
			{
				removeSemaphore($semaphore_id) ;//DERRICK not too sure about this
				throw new Exception('Failed to acquire semaphore.\n'.serialize(debug_backtrace())) ;
			}
			else
			{
				return true ;
			}
		}
		catch(Exception $e)
		{
			throw $e ;
		}
	}

	/**
	* $semaphore_id must be of type semaphore resource
	*/
	protected static function releaseSemaphore($semaphore_id)// Release semaphore
	{
		try
		{
			if(! checkResource($semaphore_id, "sysvsem"))//DERRICK need to find out ACTUAL type returned
			{
				throw new Exception('Semaphore id provided was not a resource or was wrong type. '.serialize(debug_backtrace())) ;
			}

			if (! sem_release($semaphore_id))
			{
				throw new Exception("Failed to release semaphore.\n".serialize(debug_backtrace())) ;
			}
			else
			{
				return true ;
			}
		}
		catch(Exception $e)
		{
			throw $e ;
		}
	}	

	protected static function removeSemaphore($semaphore_id)// Remove semaphore
	{
		try
		{
			if(! checkResource($semaphore_id, "sysvsem"))//DERRICK need to find out ACTUAL type returned
			{
				throw new Exception('Semaphore id provided was not a resource or was the wrong type. '.serialize(debug_backtrace())) ;
			}

			if (sem_remove($semaphore_id))
			{
				//DERRICK need to take the semaphore out of the "registry"
				return true ;
			}
			else
			{
				throw new Exception("Failed to remove semaphore.\n".serialize(debug_backtrace())) ;
			}
		}
		catch(Exception $e)
		{
			throw $e ;
		}
	}

	/**
	*
	* resource types reference http://us.php.net/manual/en/resource.php
	*/
	protected static function checkResource($resource, $expected_type = "")
	{
		if(! is_resource($resource))
		{
			return false ;
		}

		if("" == $expected_type)//we don't really care in this case what the type is...
		{
			return true ;
		}
		elseif(strtoupper($expected_type) != strtoupper(get_resource_type($resource)))
		{
			return false ;
		}
		else
		{
			return true ;
		}
	}
}


class SharedMemoryException extends Exception
{
	function __construct()
	{
		parent::__construct()
		error_log(parent::getTraceAsString()) ;
	}
}


class DSharedMemory extends DSemaphore
{
	/**
	* $shared_memory_key type int
	* $semaphore_id type semaphore resource
	* $kilobytes int
	* $permissions octal
	*/
	protected static function attachSharedMemory($shared_memory_key = 100001, $semaphore_id, $kilobytes = 10, $permissions = 0666)// Attach shared memory segment
	{
		try
		{
			if(! checkResource($semaphore_id, 'sysvsem'))//DERRICK need to find out ACTUAL type returned
			{
				throw new Exception('Semaphore argument was not a resource or was wrong type.\n'.serialize(debug_backtrace)) ;
			}
			if((! is_numeric($shared_memory_key)) || (100000 <= $shared_memory_key))
			{
				throw new Exception('Shared memory key was not a number or too low a number.\n'.serialize(debug_backtrace())) ;
			}
			$shared_memory_id = shm_attach($shared_memory_key, $kilobytes, $permissions);
			if(! checkResource($shared_memory_id, 'sysvshm'))//DERRICK need to find out ACTUAL type returned
			{
				//removeSemaphore($semaphore_id);//DERRICK not too sure about this
				throw new Exception('Failed to attach memory segment.\n'.serialize(debug_backtrace())) ;
			}
			else
			{
				return $shared_memory_id ;
			}
		}
		catch(Exception $e)
		{
			throw $e ;
		}
	}

	/**
	* $data_to_write any type of variable 
	* $variable_key type string key by which to refer to $data_to_write
	* $shared_memory_id  resource type shared_memory
	* $semaphore_id resource type semaphore
	*/ 
	protected static function write($data_to_write = "", $variable_key, $shared_memory_id, $semaphore_id)//save changed or new information to this shared_memory "cell"
	{
		try
		{
			if(! checkResource($shared_memory_id, 'sysvshm'))
			{
				throw new Exception('Shared memory argument was not proper resource.\n'.serialize(debug_backtrace())) ;
			}
			if(! checkResource($semaphore_id, 'sysvsem'))//DERRICK need to find out ACTUAL type returned
			{
				throw new Exception('Semaphore argument was not proper resource.\n'.serialize(debug_backtrace())) ;
			}
			if("" == $variable_key)
			{
				throw new Exception('Variable key argument missing.\n'.serialize(debug_backtrace())) ;
			}
			if("" == $data_to_write)
			{
				throw new Exception('Data argument missing.\n'.serialize(debug_backtrace())) ;
			}

			if (! shm_put_var($shared_memory_id, $variable_key, $data_to_write))
			{
				// Clean up nicely
				removeSemaphore($semaphore_id);//DERRICK not too sure about this
				removeSharedSegment($shared_memory_id);//DERRICK not too sure about this
				throw new Exception('Failed to put data into shared memory.\n'.serialize(debug_backtrace()));
			}
			else
			{
				return true ;
			}
		}
		catch(Exception $e)
		{
			throw $e ;
		}
	}

	/**
	* 
	* 
	* $shared_memory_id resource type shared_memory obtained from previous shm_attach operation 
	* $variable_key int variable index assigned to data stored in ram
	*/ 
	protected static function read($shared_memory_id, $variable_key)//pull shared_memory "cell" out of ram, and return it to the caller
	{
		try
		{
			if(! checkResource($shared_memory_id, 'sysvshm'))//DERRICK need to find out ACTUAL type returned
			{
				throw new Exception('Shared memory resource argument was invalid.\n'.serialize(debug_backtrace()));
			}
			if(! is_numeric($variable_key))
			{
				throw new Exception('Variable key argument was empty or wrong type.\n'.serialize(debug_backtrace()));
			}
			$variable_to_return = shm_get_var($shared_memory_id, $variable_key);
			if ($variable_to_return === false)
			{
				throw new Exception("Failed to retreive requested data from shared memory.\n" .debug_backtrace()) ;
			}
			else
			{
				return $variable_to_return ;
			}
		}
		catch(Exception $e)
		{
			throw $e ;
		}
	}

	/**
	* 
	* $shared_memory_id resource type shared_memory
	*/ 
	protected static function removeSharedSegment($shared_memory_id)// Remove shared memory segment
	{
		try
		{
			if(! checkResource($shared_memory_id, 'sysvshm'))
			{
				throw new Exception('Shared memory id argument not a resource, wrong type or empty.\n'.serialize(debug_backtrace()));
			}
			if (shm_remove ($shared_memory_id))
			{
				return true ;
			}
			else
			{
				throw new Exception("Failed to remove shared memory segment from ram.\n".serialize(debug_backtrace())) ;
			}
		}
		catch(Exception $e)
		{
			throw $e ;
		}
	}


	
}


class AsynchronousDataRegistry extends DSharedMemory
{
	private static $memory_size = 512 ;
	private static $semaphore_key = 1 ;
	private static $shared_memory_key = 100001 ;
	private static $variable_key = 2 ;
	private $semaphore_id ;
	private $shared_memory_id ;
//$MEMSIZE = 512; //  size of shared memory to allocate
//$SEMKEY = 1;   //  Semaphore key
//$SHMKEY = 2;   //  Shared memory key

	function __construct()
	{
		try
		{
			// Acquire the semaphore
			if(! acquireSemaphore($semaphore_id) )
			{
				// Create a semaphore if it does not already exist
				$this->semaphore_id = createSemaphore($semaphore_key) ;
				acquireSemaphore($semaphore_id) ;
			}
			// Attach shared memory
			$this->shared_memory_id = attachSharedMemory($shared_memory_key, $this->semaphore_id, $memory_size);
		}
		catch(Exception $e)
		{
			throw $e ;
		}
	}
	
	function __destruct()//remove expired entries in registry if any and release semaphore
	{
		try
		{
			//remove expired entries in registry if any
			//import the registry array from shared memory
			// Read variable 1
			$old_registry_array = read($this->shared_memory_id, $shared_memory_key) ; 
			$new_registry_array = new array() ;
			$reg_entries = count($old_registry_array) ;
			for($X = 0 ; $X <= $reg_entries ; ++$X)
			{
				if((60*60*2) < (mktime() - $old_registry_array[$X]['last_accessed']))
				{//last accessed less than two hours ago...
					$new_registry_array[] = $old_registry_array[$X] ;
				}
			}
			//save the new registry array
			write($this->shared_memory_id, $shared_memory_key ,$new_registry_array) ;
		
			// Release semaphore
			releaseSemaphore($this->semaphore_id) ;
		}
		catch(Exception $e)
		{
			throw $e ;
		}
	}


			// Write variable 1
			if (!shm_put_var($shm_id, 1, "XXXXXX 1"))
			{
			    echo "Failed to put var 1 in shared memory $shm_id.\n";

			    // Clean up nicely
			    sem_remove($sem_id);
			    shm_remove($shm_id);
			    exit;
			}
			else
			    echo "Wrote var1 to shared memory.\n";

			// Write variable 2
			if (!shm_put_var($shm_id, 2, "YYYYYYY 2"))
			{
			    echo "Failed to put var 2 on shared memory $shm_id.\n";

			    // Clean up nicely
			    sem_remove($sem_id);
			    shm_remove ($shm_id);
			    exit;
			}
			else
			    echo "Wrote var2 to shared memory.\n";

			// Read variable 1
			$var1 = shm_get_var($shm_id, 1);
			if ($var1 === false)
			{
			    echo "Failed to retreive Var 1 from Shared memory $shm_id, " .
				 "return value=$var1.\n";
			}
			else
			    echo "Read var1=$var1.\n";

			// Read variable 1
			$var2 = shm_get_var ($shm_id, 2);
			if ($var1 === false)
			{
			     echo "Failed to retrive Var 2 from Shared memory $shm_id, " .
				  "return value=$var2.\n";
			}
			else
			    echo "Read var2=$var2.\n";


			/*// Remove shared memory segment
			if (shm_remove ($shm_id))
			    echo "Shared memory successfully removed.\n";
			else
			    echo "Failed to remove $shm_id shared memory.\n";

			// Remove semaphore
			if (sem_remove($sem_id))
			    echo "Semaphore removed successfully.\n";
			else
			    echo "Failed to remove $sem_id semaphore.\n";*/
		}
		catch(Exception $e)
		{
			throw $e ;
		}
	}

//keep track of shared_memory cells that are created, and clean them up after x amount of time of no activity
	function register($data_label = "")//create a new entry in the register
	{
		try
		{
			if(1 > strlen($data_label))
			{
				throw new Exception('Missing Data label argument.\n'.serialize(debug_backtrace()));
			}
			if(! $this->checkRegister($data_label))
			{
				$old_registry_array = read($this->shared_memory_id, $shared_memory_key) ; 
				$old_registry_array[] = new array('data_label'=>$data_label,'shared_memory_key'=>getNewKey(),''=>'') ;
				//save the new registry array
				write($this->shared_memory_id, $shared_memory_key ,$old_registry_array) ;

				$register = read(
			}
			else
			{
				throw new Exception('Data label is already in use.\n'.serialize(debug_backtrace()));
			}
		}
		catch(Exception $e)
		{
			throw $e ;
		}
	}



	function checkRegister($data_label = "")
	{//if arg is empty, return array of all labels and when they were last accessed
		if("" == $data_label)
		{
		}
		else
		{
			if(shm_has_var($data_label))
			{
			}
			
		}
	}

	function updateRegister($data_label = "")
	{//set the last access time of $data_label to now
	}



}

class AsynchronousDataAccessObject extends DSharedMemory
{

	public $memory_size = 512 ;
	private $semaphore_key ;
	private $shared_memory_key ;

	public $register ;
	/**
	* $data_label string label of data to either retreive or store $shared_data under
	* $shared_data any type  If not empty, save under $data_label.
	*/
	function __construct($data_label = "", $shared_data = "")//check to see if there is already a shared_memory "cell" by this name, if not, create it
	{
		try
		{
			if(0 != strlen($data_label))
			{
				if($this->checkRegister($data_label))
				{
					 ;
				}
				else
				{
					
				}
			}
			else
			{
				throw new Exception('No data label supplied.\n'.serialize(debug_backtrace()));
			}
		}
		catch(Exception $e)
		{
			throw $e ;
		}
	}



	function remove()//delete this shared_memory "cell" from ram
	{
		$this->removeSharedSegment($shm_id) ;
		$this->removeSemaphore($sem_id) ;
	}


	function createNew()//create a new shared_memory "cell" if one does not already exist
	{
	}


	private function persist()//serialize and save all datapoints for this instance into memory, update semaphore registry, run callback to potentially save data to DB or file
	{
	}

	public function saveData($data_to_save = "")
	{

	}

	/**
	* $data_key string name of piece of data to retreive from shared memory
	*/
	public function retreiveData($data_label = "")
	{

	}

	function __destruct()//find all "expired" memory segments and remove them so we do not run out of ram
	{
	}
}

//AsynchronousDataAccessObject
$adao = new AsynchronousDataAccessObject('derrick_session');
$d_array = new array('first'=>'Derrick','middle'=>'Ray','last'=>'McCurdy') ;
$adao->saveData($d_array) ;
$new_d_array = $adao->retreiveData($d_array) ;



/*
$MEMSIZE = 512; //  size of shared memory to allocate
$SEMKEY = 1;   //  Semaphore key
$SHMKEY = 2;   //  Shared memory key

echo "Start.\n";

// Create a semaphore
$sem_id = sem_get($SEMKEY, 1) ;
if ($sem_id === false)
{
    echo "Failed to create semaphore";
    exit;
}
else
    echo "Created semaphore $sem_id.\n";

// Acquire the semaphore
if (! sem_acquire($sem_id))
{
    echo "Failed to acquire semaphore $sem_id.\n";
    sem_remove($sem_id);
    exit;
}
else
    echo "Success acquiring semaphore $sem_id.\n";

// Attach shared memory
$shm_id = shm_attach($SHMKEY, $MEMSIZE);
if ($shm_id === false)
{
    echo "Fail to attach shared memory.\n";
    sem_remove($sem_id);
    exit;
}
else
    echo "Success to attach shared memory : $shm_id.\n";

// Write variable 1
if (!shm_put_var($shm_id, 1, "XXXXXX 1"))
{
    echo "Failed to put var 1 in shared memory $shm_id.\n";

    // Clean up nicely
    sem_remove($sem_id);
    shm_remove($shm_id);
    exit;
}
else
    echo "Wrote var1 to shared memory.\n";

// Write variable 2
if (!shm_put_var($shm_id, 2, "YYYYYYY 2"))
{
    echo "Failed to put var 2 on shared memory $shm_id.\n";

    // Clean up nicely
    sem_remove($sem_id);
    shm_remove ($shm_id);
    exit;
}
else
    echo "Wrote var2 to shared memory.\n";

// Read variable 1
$var1 = shm_get_var($shm_id, 1);
if ($var1 === false)
{
    echo "Failed to retreive Var 1 from Shared memory $shm_id, " .
         "return value=$var1.\n";
}
else
    echo "Read var1=$var1.\n";

// Read variable 1
$var2 = shm_get_var ($shm_id, 2);
if ($var1 === false)
{
     echo "Failed to retrive Var 2 from Shared memory $shm_id, " .
          "return value=$var2.\n";
}
else
    echo "Read var2=$var2.\n";

// Release semaphore
if (!sem_release($sem_id))
    echo "Failed to release $sem_id semaphore.\n";
else
    echo "Semaphore $sem_id released.\n";

// Remove shared memory segment
if (shm_remove ($shm_id))
    echo "Shared memory successfully removed.\n";
else
    echo "Failed to remove $shm_id shared memory.\n";

// Remove semaphore
if (sem_remove($sem_id))
    echo "Semaphore removed successfully.\n";
else
    echo "Failed to remove $sem_id semaphore.\n";

echo "End.\n";
*/
?>




<?php
/*/ Create 100 byte shared memory block with system id of 0xff3
$shm_id = shmop_open(0xff3, "c", 0644, 100);

if(!$shm_id)
{
    echo "Couldn't create shared memory segment\n";
}

// Get the size of shared memory block
$shm_size = shmop_size($shm_id);
echo "SHM Block Size: ". $shm_size . " has been created.\n";

// Write a test string into shared memory
$shm_bytes_written = shmop_write($shm_id, "my shared memory block", 0);

if($shm_bytes_written != strlen("my shared memory block"))
{
    echo "Couldn't write the entire length of data\n";
}

// Read back the string
$my_string = shmop_read($shm_id, 0, $shm_size);

if(!$my_string)
{
    echo "Couldn't read from shared memory block\n";
}

echo "The data inside shared memory was: ".$my_string."\n";

// Delete the block and close the shared memory segment

if(!shmop_delete($shm_id))
{
    echo "Couldn't mark shared memory block for deletion.";
}

shmop_close($shm_id);
*/
?>
