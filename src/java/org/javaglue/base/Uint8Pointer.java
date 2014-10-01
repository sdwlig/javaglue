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
import java.io.UnsupportedEncodingException;


/**
 * Represents a pointer or reference to a native byte value.
 * @see NumberPointer
 */
public class Uint8Pointer extends NumberPointer<Byte> {
	
    /*
     * (non-Javadoc)
     * 
     * @see org.javaglue.base.NativeObject#NativeObject(InstancePointer)
     */
	public Uint8Pointer(InstancePointer pInstance) {
		super(pInstance);
	}

    /*
     * (non-Javadoc)
     * 
     * @see org.javaglue.base.NativeObject#NativeObject(InstancePointer, boolean)
     */
    public Uint8Pointer(InstancePointer pointer, boolean remote) {
        super(pointer,remote);
    }
    /**
     * Create a new Uint8Pointer pointing to the address passed, marked remote or not by flag.
     * @param pointer Address
     * @param remote Whether this is remote (allocated from C++) or not (allocated from Java).
     */
    public Uint8Pointer(long pointer, boolean remote) {
        super(new InstancePointer(pointer),remote);
    }
    /**
     * This makes it easy to create a Uint8Pointer that points to a particular value.
     * Problem is, this version doesn't get the remote flag.  For NULL, false, otherwise assume true;
     * @param pointer Native value of pointer
     */
    public Uint8Pointer(long pointer) {
        super(new InstancePointer(pointer),pointer==0?false:true);
    }

    /**
     * Create native variable and initialise it.
     * 
     * @param value Value to initialise native value.
     */
	public Uint8Pointer(byte value) {
		super(new InstancePointer(_create(value)),false);
	}

	private static native long _create(byte value);

	private native void _dispose(long pInstance);

	private native byte _get(long pInstance);

	private native long _next(long pInstance);

	private native void _set(long pInstance, byte value);

	/**
	 * @{inheritdoc}
	 * @see org.javaglue.base.NativeObject#delete()
	 */
	@Override
	public void delete() {
		if(this.remote) {
			throw new RuntimeException("Instance created by the library! It's not allowed to dispose it.");
		}

		if(!this.deleted && this.object.pointer != 0) {
			_dispose(object.pointer);
		    this.deleted = true;
		   	this.object.pointer = 0;
		}
	}
	/**
	 * @{inheritdoc}
	 * @see org.javaglue.base.NumberPointer#doubleValue()
	 */
	@Override
	public double doubleValue() {
		return _get(object.pointer);
	}
	/**
	 * @{inheritdoc}
	 * @see org.javaglue.base.NativeObject#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(Object obj) {
		if (obj instanceof Uint8Pointer) {
			return this._get(object.pointer) == ((Uint8Pointer) obj)._get(object.pointer);			
		}
		return super.equals(obj);
	}
	/**
	 * @{inheritdoc}
	 * @see org.javaglue.base.NumberPointer#floatValue()
	 */
	@Override
	public float floatValue() {
		return (float) _get(object.pointer);
	}
	/**
	 * @{inheritdoc}
	 * @see org.javaglue.base.NumberPointer#get()
	 */
	public Byte get()
	{
		return _get(object.pointer);
	}
	/**
	 * @{inheritdoc}
	 * @see org.javaglue.base.NativeObject#hashCode()
	 */
	@Override
	public int hashCode() {
		return intValue();
	}

	/**
	 * @{inheritdoc}
	 * @see org.javaglue.base.NumberPointer#intValue()
	 */
	@Override
	public int intValue() {
		return (int) _get(object.pointer);
	}

	/**
	 * @{inheritdoc}
	 * @see org.javaglue.base.NumberPointer#longValue()
	 */
	@Override
	public long longValue() {
		return (long) _get(object.pointer);
	}

	/**
	 * @{inheritdoc}
	 * @see org.javaglue.base.NumberPointer#next()
	 */
	@Override
	public Uint8Pointer next() {
		long ptr = _next(object.pointer);
		if(ptr==0)return null;		
		return new Uint8Pointer(new InstancePointer(ptr));
	}
	
	/**
	 * @{inheritdoc}
	 * @see org.javaglue.base.NumberPointer#set(java.lang.Object)
	 */
	public void set(Byte value) {
		_set(object.pointer, value);
	}

	/**
	 * @{inheritdoc}
	 * @see org.javaglue.base.NativeObject#toString()
	 */
	@Override
	public String toString() {
	    byte bytes[] = new byte[1];
	    bytes[0] = get();
	    String s = null;
	    try {
		s = new String(bytes, "UTF-8");
	    } catch (UnsupportedEncodingException uee) {}
	    return s;
	}

	public void finalize() {
		if(!this.remote && !this.deleted && this.object.pointer != 0) {
			delete();
		}
	}
}
