package be.zajac.ui;
import nme.display.DisplayObject;

/**
 * Interface for components that will draw skins for subclasses of BaseComponent.
 * @author Aleksandar Bogdanovic
 */

interface ISkin {

	/**
	 * Draw skins for all states of client component.
	 * @param	client	BaseComponent which skins should be created.
	 * @return		Hash map with skins where keys are comonent states.
	 */
	function draw(client: BaseComponent): Hash<DisplayObject>;
	
}