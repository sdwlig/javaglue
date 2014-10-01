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
import org.javaglue.std.*;
import org.javaglue.base.*;

/**
 * Allows allocation of a memory region and accessing it char wise.
 * There is a single use for creating a Java byte[] and supporting pin/unpin.
 * The rest are static utility methods for various purposes.
 */
public class ByteArray {
    private byte[] bytes = null;
    private boolean pinned = false;
    private BytePointer bp = new BytePointer(0); // New null pointer
    private boolean failed = false; // We've already failed a call
    private boolean[] copied = new boolean[1]; // So we can have an extra 'out' parameter to the native 'pin()'.
    /**
     * Create a new byte array of given size.
     * @param size The size of the byte array to create;
     */
    public ByteArray(int size) {
	bytes = new byte[size];
	if (bytes == null) throw new NullPointerException();
    }
    public int length() { return bytes.length; }

    // Not the best, but makes coding easier.  Just count on correct calls to unpin().
    // See: http://java.sys-con.com/node/995699
    // public finalize() { 	unpin();    }
    /**
     * Pin (call GetByteArray() from JNI) to lock memory in Java for native use.
     */
    public BytePointer pin() {
	if (bytes == null) return null;
	if (!pinned) {
	    long bpn = pin(bytes, copied);
	    bp.setInstancePointer(bpn, true); // Store new pointer, and note it is not to be deleted in C!
	    pinned = true;
	    if (copied[0]) return null; // Just temporary restriction for testing.
	}
	return bp;
    }
    /**
     * Unpin (call ReleaseByteArray() from JNI) to unlock memory in Java.  Can safely be called extra times.
     */
    public boolean unpin() {
	boolean ok = true;
	if (pinned) {
	    long bpn = bp.getInstancePointer().pointer;
	    ok = unpin(bytes, bpn);
	    if (!ok) failed = true;
	    pinned = false;
	}
	return ok;
    }
    public BytePointer getBytePointer() {
	if (bp == null || failed) return null;
	if (!pinned) pin();
	return bp;
    }
    public byte[] getByteArray() {
	return bytes;
    }
    public static native long pin(byte[] bytes, boolean[] copied);
    public static native boolean unpin(byte[] bytes, long bpl);

    // Static utility methods:
    
    // ByteArray (byte[]) / ByteVector (vector<unsigned char>) methods
    public static long memset(IByteVector bv, long b, long len) {
        return memsetByteVectorNative(bv, b, len);
    }
    public static native long memsetByteVectorNative(IByteVector bv, long b, long len);

    public static byte[] byteArray(IByteVector byteVector) {
	return byteArray(byteVector, false);
    }
    public static byte[] byteArray(IByteVector byteVector, boolean fullAllocation) {
	long bvn = byteVector.getInstancePointer().pointer;
	if (bvn == 0L) return null; // Just pass it on
	return byteArrayNative(bvn, fullAllocation);
    }
    public static native byte[] byteArrayNative(long ptr, boolean fullAllocation);

    public static ByteVector byteVector(byte[] bytes) {
	return byteVector(bytes, 0);
    }
    public static ByteVector byteVector(long reserve) {
        long _returnObjPtr = byteVectorNativeReserve(reserve);
        return new ByteVector(new InstancePointer(_returnObjPtr));
    }
    public static native long byteVectorNativeReserve(long reserve);

    public static ByteVector byteVector(byte[] bytes, long reserve) {
	long _returnObjPtr = byteVectorNative(bytes, reserve);
	return new ByteVector(new InstancePointer(_returnObjPtr));
    }
    public static native long byteVectorNative(byte[] bytes, long reserve);

    public static byte[] copy(IByteVector bv, byte[] ba) {
	long bvn = bv.getInstancePointer().pointer;
	if (bvn == 0L) return null; // Just pass it on
	return copyNativebv2ba(bvn, ba);
    }
    public static native byte[] copyNativebv2ba(long bv, byte[] ba);

    public static ByteVector copy(byte[] ba, IByteVector bv) {
	long bvn = bv.getInstancePointer().pointer;
	if (bvn == 0L) return null; // Just pass it on
	long _returnObjPtr = copyNativeba2bv(ba, bvn);
	return new ByteVector(new InstancePointer(_returnObjPtr));
    }
    public static native long copyNativeba2bv(byte[] ba, long bv);

    // ByteArray / BytePointer methods
    public static long memset(BytePointer bp, long b, long len) {
	long bpn = bp.getInstancePointer().pointer;
        return memsetBytePointerNative(bpn, b, len);
    }
    public static native long memsetBytePointerNative(long bp, long b, long len);

    public static byte[] byteArray(BytePointer bp, long size) {
	long bpn = bp.getInstancePointer().pointer;
	return byteArrayNativebp(bpn, size);
    }
    public static native byte[] byteArrayNativebp(long bp, long size);

    public static BytePointer bytePointer(byte[] bytes) {
	return bytePointer(bytes, bytes.length);
    }
    public static BytePointer bytePointer(byte[] bytes, long size) {
	return bytePointerNative(bytes, size);
    }
    public static native BytePointer bytePointerNative(byte[] bytes, long size);

    // Copy from byte array to byte pointer up to size or ba.length.
    // Return amount of data written.
    public static long copy(byte[] ba, BytePointer bp, long size) {
	long bpn = bp.getInstancePointer().pointer;
	if (bpn == 0) error(0, "Bad bp instancePointer == null");
	return copyNativeba2bp(ba, bpn, size);
    }
    public static native long copyNativeba2bp(byte[] ba, long bp, long size);

    // Copy from byte pointer to array up to size or ba.length.
    // Return amount of data written.
    public static long copy(BytePointer bp, long size, byte[] ba) {
	long bpn = bp.getInstancePointer().pointer;
	if (bpn == 0) error(0, "Bad bp instancePointer == null");
	if (ba == null) error(0, "Bad byteArray == null!");
	return copyNativebp2ba(bpn, size, ba);
    }
    public static native long copyNativebp2ba(long bp, long size, byte[] ba);

    // Like the last copy except that the byte array might be reallocated,
    // always use return value to overwrite ba references;
    public static byte[] copyRealloc(BytePointer bp, long size, byte[] ba) {
	long bpn = bp.getInstancePointer().pointer;
	return copyNativebp2baRealloc(bpn, size, ba);
    }
    public static native byte[] copyNativebp2baRealloc(long bp, long size, byte[] ba);

    // Testing methods

    public static BytePointer static255() {
	return new BytePointer(new InstancePointer(static255Native()));
    }
    public static native long static255Native();

    public static boolean static255bad() {
	return static255badNative();
    }
    public static native boolean static255badNative();
    
    // http://stackoverflow.com/questions/3238388/android-out-of-memory-exception-in-gallery
    /*
    public static void logHeap(Class clazz) {
	Double allocated = new Double(Debug.getNativeHeapAllocatedSize())/new Double((1048576));
	Double available = new Double(Debug.getNativeHeapSize())/1048576.0;
	Double free = new Double(Debug.getNativeHeapFreeSize())/1048576.0;
	DecimalFormat df = new DecimalFormat();
	df.setMaximumFractionDigits(2);
	df.setMinimumFractionDigits(2);
	
	Log.d(APP, "debug. =================================");
	Log.d(APP, "debug.heap native: allocated " + df.format(allocated) + "MB of " + df.format(available) + "MB (" + df.format(free) + "MB free) in [" + clazz.getName().replaceAll("com.myapp.android.","") + "]");
	Log.d(APP, "debug.memory: allocated: " + df.format(new Double(Runtime.getRuntime().totalMemory()/1048576)) + "MB of " + df.format(new Double(Runtime.getRuntime().maxMemory()/1048576))+ "MB (" + df.format(new Double(Runtime.getRuntime().freeMemory()/1048576)) +"MB free)");
	System.gc();
	System.gc();
	
	// don't need to add the following lines, it's just an app specific handling in my app        
	// if (allocated>=(new Double(Runtime.getRuntime().maxMemory())/new Double((1048576))-MEMORY_BUFFER_LIMIT_FOR_RESTART)) {
	//   android.os.Process.killProcess(android.os.Process.myPid());
	// }
    }
    */
    /*
    public static byte[] byteArray(VoidPointer bp, long size) {
	long bpn = bp.getInstancePointer().pointer;
	return byteArrayNativebp(bpn, size);
    }
    public static native byte[] byteArrayNativebp(long bp, long size);
    public static VoidPointer bytePointer(byte[] bytes) {
	return bytePointer(bytes, bytes.length);
    }
    public static VoidPointer bytePointer(byte[] bytes, long size) {
	return bytePointerNative(bytes, size);
    }
    public static native VoidPointer bytePointerNative(byte[] bytes, long size);
    */
    public static void message(String msg) {
	System.err.println(msg);
    }
    public static void error(int err, String msg) {
	System.err.printf("%d %s\n", err, msg);
    }
}
