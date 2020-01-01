
# executed from src
# takes list of target packages in form of package/

target=local

package/% :
	(cd $*; $(MAKE) $(target))
