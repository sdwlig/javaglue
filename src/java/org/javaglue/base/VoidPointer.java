/* This source file is part of XBiG
 *     (XSLT Bindings Generator)
 * For the latest info, see http://sourceforge.net/projects/javaglue/
 * 
 * Copyright (c) 2005 netAllied GmbH, Tettnang
 * Also see acknowledgements in Readme.html
 * 
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free Software
 * Foundation; either version 2 of the License, or (at your option) any later
 * version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License along with
 * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
 * Place - Suite 330, Boston, MA 02111-1307, USA, or go to
 * http://www.gnu.org/copyleft/lesser.txt.
 */
package org.javaglue.base;

/**
 * Represents the C/C++ type void*.
 * @see NumberPointer
 */
public class VoidPointer extends NativeObject {
	
    /*
     * (non-Javadoc)
     * 
     * @see org.javaglue.base.NativeObject#NativeObject(InstancePointer)
     */
	public VoidPointer(InstancePointer pInstance) {
		super(pInstance);
	}

    /*
     * (non-Javadoc)
     * 
     * @see org.javaglue.base.NativeObject#NativeObject(InstancePointer, boolean)
     */
	public VoidPointer(InstancePointer pointer, boolean b) {
		super(pointer,b);
	}

    /**
     * Create a new VoidPointer pointing to the address passed, marked remote or not by flag.
     * @param pointer Address
     * @param remote Whether this is remote (allocated from C++) or not (allocated from Java).
     */
    public VoidPointer(long pointer, boolean remote) {
        super(new InstancePointer(pointer),remote);
    }
    /**
     * This makes it easy to create a VoidPointer that points to a particular value.
     * Problem is, this version doesn't get the remote flag.  For NULL, false, otherwise assume true;
     * @param pointer Native value of pointer
     */
    public VoidPointer(long pointer) {
        super(new InstancePointer(pointer),pointer==0?false:true);
    }

	private native void _dispose(long pInstance);

	/**
	 * @{inheritdoc}
	 * @see org.javaglue.base.NativeObject#delete()
	 */
	@Override
	public void delete() {
		if(this.remote) {
			throw new RuntimeException("Instance created by the library! It's not allowed to dispose it.");
		}

		//if(!this.deleted) {
		//	_dispose(object.pointer);
		//    this.deleted = true;
		//   	this.object.pointer = 0;
		//}
		throw new RuntimeException("deleting ‘void*’ is undefined");
	}
	/**
	 * @{inheritdoc}
	 * @see org.javaglue.base.NativeObject#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(Object obj) {
		if (obj instanceof VoidPointer) {
			return this.object.pointer == ((VoidPointer) obj).object.pointer;			
		}
		return super.equals(obj);
	}

	public void finalize() {
		if(!this.remote && !this.deleted) {
			delete();
		}
	}
}
